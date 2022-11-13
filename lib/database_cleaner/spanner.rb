# frozen_string_literal: true

require "database_cleaner/spanner/version"
require "database_cleaner/core"
require "database_cleaner/spanner/deletion"

DatabaseCleaner[:spanner].strategy = :deletion
