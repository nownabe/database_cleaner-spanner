# frozen_string_literal: true

require "database_cleaner/spanner"
require "database_cleaner/spec"

RSpec.describe DatabaseCleaner::Spanner do
  it "has a version number" do
    expect(DatabaseCleaner::Spanner::VERSION).not_to be nil
  end

  it_behaves_like "a database_cleaner adapter"
end
