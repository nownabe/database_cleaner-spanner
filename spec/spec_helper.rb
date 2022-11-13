# frozen_string_literal: true

require "database_cleaner/spanner"

require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"
require "google/cloud/spanner/admin/instance"

class SpannerAdmin
  def self.get_project_id
    return ENV["PROJECT_ID"] if ENV["PROJECT_ID"]

    Google::Cloud::Spanner.default_credentials.project_id
  end

  def initialize(project_id:, instance_id:, database_id:)
    @project_id = project_id
    @instance_id = instance_id
    @database_id = database_id
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
    schema_path = File.join(__dir__, "schema.sql")
    File.read(schema_path).split(";").map(&:strip).reject(&:empty?)
  end

  def instance_exists?
    true
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

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.add_setting :project_id
  config.add_setting :instance_id
  config.add_setting :database_id

  config.project_id = SpannerAdmin.get_project_id
  config.instance_id = ENV.fetch("SPANNER_INSTANCE_ID")
  config.database_id = ENV.fetch("SPANNER_DATABASE_ID", "test#{Time.now.to_i}")

  admin = SpannerAdmin.new(
    project_id: config.project_id,
    instance_id: config.instance_id,
    database_id: config.database_id
  )

  # Create instance and database for testing
  config.before(:suite) do
    admin.create_instance if ENV["SPANNER_EMULATOR_HOST"]
    admin.create_database
  end

  # Delete database for testing
  config.after(:suite) do
    admin.drop_database
  end
end
