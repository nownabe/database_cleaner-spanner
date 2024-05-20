# frozen_string_literal: true

if ENV.fetch("COVERAGE", "true") == "true"
  require "simplecov"
  SimpleCov.start do
    add_filter "spec/"
  end

  if ENV["CI"] == "true"
    require "simplecov-cobertura"
    SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
  end
end

require "database_cleaner/spanner"

require "google/cloud/spanner"

dotenv = File.expand_path("local.env", __dir__)
if File.exist?(dotenv)
  File.read(dotenv).each_line do |line|
    line.split("=").tap do |key, value|
      ENV[key] = value.gsub(/^['"]|['"]$/, "")
    end
  end
end

require_relative "spanner_admin"

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

  if ENV["SPANNER_EMULATOR_HOST"]
    config.project_id = "test-project"
    config.instance_id = "test-instance"
    config.database_id = "test#{Time.now.to_i}"
  else
    config.project_id = SpannerAdmin.get_project_id
    config.instance_id = ENV.fetch("SPANNER_INSTANCE_ID")
    config.database_id = ENV.fetch("SPANNER_DATABASE_ID", "test#{Time.now.to_i}")
  end

  admin = SpannerAdmin.new(
    project_id: config.project_id,
    instance_id: config.instance_id,
    database_id: config.database_id,
    schema_file: File.expand_path("./schema.sql", __dir__)
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
