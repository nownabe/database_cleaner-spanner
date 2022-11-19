# frozen_string_literal: true

require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"
require "google/cloud/spanner/admin/instance"

class SpannerAdmin
  def self.get_project_id
    return ENV["PROJECT_ID"] if ENV["PROJECT_ID"]

    Google::Cloud::Spanner.default_credentials.project_id
  end

  def initialize(project_id:, instance_id:, database_id:, schema_file:)
    @project_id = project_id
    @instance_id = instance_id
    @database_id = database_id
    @schema_file = schema_file
  end

  def create_instance
    return if instance_exists?

    instance_admin.create_instance(
      parent: project_path,
      instance_id: @instance_id,
      instance: {
        name: instance_path,
        config: instance_config_path,
        display_name: @instance_id,
        node_count: 1
      }
    ).wait_until_done!
  end

  def create_database
    database_admin.create_database(
      parent: instance_path,
      create_statement: "CREATE DATABASE `#{@database_id}`",
      extra_statements: ddls
    ).wait_until_done!
  end

  def drop_database
    database_admin.drop_database(database: database_path)
  end

  private

  def ddls
    File.read(@schema_file).split(";").map(&:strip).reject(&:empty?)
  end

  def instance_exists?
    instance_admin.list_instances(parent: project_path)
      .any? { |instance| instance.name == instance_path }
  end

  def project_path
    @project_path ||= instance_admin.project_path(project: @project_id)
  end

  def instance_config_path
    @instance_config_path ||= instance_admin.instance_config_path(
      project: @project_id,
      instance_config: "regional-us-central1"
    )
  end

  def instance_path
    @instance_path ||= instance_admin.instance_path(
      project: @project_id,
      instance: @instance_id
    )
  end

  def database_path
    @database_path ||= database_admin.database_path(
      project: @project_id,
      instance: @instance_id,
      database: @database_id
    )
  end

  def instance_admin
    @instance_admin ||= Google::Cloud::Spanner::Admin::Instance.instance_admin(
      project_id: @project_id
    )
  end

  def database_admin
    @database_admin ||= Google::Cloud::Spanner::Admin::Database.database_admin(
      project_id: @project_id
    )
  end
end
