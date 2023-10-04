# frozen_string_literal: true

# classes to simulate database_cleaner/active_record and active_record
module DatabaseCleaner
  module ActiveRecord
    class Base; end
  end
end

module ActiveRecord
  class Base
    def self.internal_metadata_table_name
      "ar_internal_metadata"
    end
  end

  class SchemaMigration
    def self.table_name
      "schema_migrations"
    end
  end
end

require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"

require "database_cleaner/spanner/deletion"

RSpec.describe DatabaseCleaner::Spanner::Deletion do
  before do
    configuration = <<~YAML
      adapter: spanner
      instance: #{RSpec.configuration.instance_id}
      project: #{RSpec.configuration.project_id}
      database: #{RSpec.configuration.database_id}
    YAML
    configuration_hash = YAML.safe_load(configuration).tap { |hash|
      hash.keys.each { |key| hash[key.to_sym] = hash.delete(key) }
    }

    configs_for = double("ActiveRecord::DatabaseConfigurations::HashConfig", configuration_hash: configuration_hash)
    configurations = double("ActiveRecord::DatabaseConfigurations", configs_for: configs_for)
    allow(ActiveRecord::Base).to receive(:configurations).and_return(configurations)
  end

  it "can generate cloud spanner client from database name when database_cleaner-active_record is in use" do
    instance = described_class.new
    expect { instance.send(:configure_client_from_active_record, :spanner) }.to_not raise_error
  end
end
