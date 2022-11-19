# frozen_string_literal: true

require "database_cleaner/strategy"
require "database_cleaner/spanner/table_dependency"

module DatabaseCleaner
  module Spanner
    class Deletion < Strategy
      SQL = <<~SQL
        WITH References AS (
          SELECT
            ccu.TABLE_NAME AS TABLE_NAME
            , tc.TABLE_NAME AS referenced_by
          FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
          INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS ccu USING (CONSTRAINT_NAME)
          WHERE
            CONSTRAINT_TYPE = "FOREIGN KEY"
            AND tc.TABLE_NAME <> ccu.TABLE_NAME
        )
        SELECT
          t.TABLE_NAME AS table_name
          , children.TABLE_NAME AS child_table_name
          , children.ON_DELETE_ACTION AS delete_action
          , r.referenced_by AS referenced_by
        FROM INFORMATION_SCHEMA.TABLES AS t
        LEFT JOIN INFORMATION_SCHEMA.TABLES AS children
          ON t.TABLE_NAME = children.PARENT_TABLE_NAME
        LEFT JOIN References AS r
          ON t.TABLE_NAME = r.table_name
        WHERE t.TABLE_TYPE = "BASE TABLE"
      SQL

      def initialize(
        only: [],
        except: [],
        batch_deletion: false,
        cache_tables: true
      )
        @only = only
        @except = except
        @batch_deletion = batch_deletion
        @cache_tables = cache_tables

        @deletable_tables = {}
      end

      def clean
        if @batch_deletion
          clean_as_batch
        else
          clean_each
        end
      end

      private

      def clean_as_batch
        client.transaction do |tx|
          tx.batch_update do |b|
            each_deletable_table do |table|
              b.batch_update("DELETE #{table} WHERE TRUE")
            end
          end
        end
      end

      def clean_each
        each_deletable_table do |table|
          client.delete(table)
        end
      end

      def deletable?(table)
        return true if @only.empty? && @except.empty?

        return @deletable_tables[table] if @deletable_tables.key?(table)

        @deletable_tables[table] =
          if @only.empty?
            !@except.include?(table)
          else
            (@only - @except).include?(table)
          end
      end

      def each_deletable_table(&block)
        each_group do |group|
          group.each do |table|
            block.call(table) if deletable?(table)
          end
        end
      end

      def each_group(&block)
        sorted_table_groups.each(&block)
      end

      def sorted_table_groups
        return @sorted_table_groups if @cache_tables && @sorted_table_groups

        dep = TableDependency.new
        result = client.execute_query(SQL)

        result.rows.each do |row|
          dep.add_child(row[:table_name], row[:child_table_name])
          dep.add_child(row[:table_name], row[:referenced_by])
        end

        @sorted_table_groups = dep.divide.map(&:tsort)
      end

      def client
        @client ||=
          if db.is_a?(Google::Cloud::Spanner::Client)
            db
          elsif db.is_a?(Hash)
            Google::Cloud::Spanner.new(
              project_id: db[:project_id],
              credentials: db[:credentials]
            ).client(db[:instance_id], db[:database_id])
          else
            configure_client_from_active_record(db)
          end
      end

      def configure_client_from_active_record(name)
        # "primary" is hardcoded in ActiveRecord
        # https://github.com/rails/rails/blob/v7.0.4/activerecord/lib/active_record/database_configurations.rb
        name = "primary" if name == :default

        # DB config from ActiveRecord
        config = ActiveRecord::Base.configurations.configs_for(name: name.to_s).configuration_hash

        # Keep metadata tables
        @except << ActiveRecord::SchemaMigration.table_name # schema_migrations
        @except << ActiveRecord::Base.internal_metadata_table_name # ar_internal_metadata

        Google::Cloud::Spanner.new(
          project_id: config[:project],
          credentials: config[:credentials]
        ).client(config[:instance], config[:database])
      end
    end
  end
end
