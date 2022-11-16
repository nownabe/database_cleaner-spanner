# Database Claner Adapter for Cloud Spanner

[![Gem Version](https://badge.fury.io/rb/database_cleaner-spanner.svg)](https://badge.fury.io/rb/database_cleaner-spanner)
![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/nownabe/database_cleaner-spanner/test/main)
[![codecov](https://codecov.io/gh/nownabe/database_cleaner-spanner/branch/main/graph/badge.svg?token=y5Dg4FpCeX)](https://codecov.io/gh/nownabe/database_cleaner-spanner)
[![Maintainability](https://api.codeclimate.com/v1/badges/ea64a23ba2c1785963e8/maintainability)](https://codeclimate.com/github/nownabe/database_cleaner-spanner/maintainability)

Clean your Cloud Spanner databases with Database Cleaner.

See also [https://github.com/DatabaseCleaner/database_cleaner](https://github.com/DatabaseCleaner/database_cleaner) for more information.

## Motivation

* You cannot use [rspec-rails's `use_transactional_fixtures` option](https://relishapp.com/rspec/rspec-rails/v/6-0/docs/transactions) for Cloud Spanner because
  [ActiveRecord Cloud Spanner Adapter](https://github.com/googleapis/ruby-spanner-activerecord) doesn't support nested transactions.
* [database_cleaner-active_record](https://github.com/DatabaseCleaner/database_cleaner-active_record) doesn't support Cloud Spanner perfectly.
  * Transaction strategy cannot be used for the same reason as the `use_transactional_fixtures` option.
  * Truncation strategy isn't available because Cloud Spanner doesn't support `TRUNCATE` statement.
  * Deletion strategy is incompatible with Cloud Spanner because `DELETE FROM <table>` statement executed by the deletion strategy doesn't work on Cloud Spanner.
* Cloud Spanner is sometimes used with [Spanner Client](https://github.com/googleapis/ruby-spanner) instead of ActiveRecord.
* If tables are interleaved, the order of deletion needs to be considered.
* If tables has foreign key constraints, the order of deletion needs to be considered.

The core ideas of database_cleaner-spanner are:

* no dependence on ActiveRecord
* consider deletion orders based on actual schema

**NOTE:** This gem determines deletion orders based on dependency graph of tables using the topological sort algorithm, which means `only` option and `except` option don't guarantees removal of as many tables as dependencies allow.

## Installation

```ruby
# Gemfile
group :test do
  gem "database_cleaner-spanner"
end
```

## Example

Configuration for RSpec on Rails:

```ruby
# spec/rails_helper.rb

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.around(:each) do |example|
    DatabaseCleaner[:spanner].cleaning do
      example.run
    end
  end
end
```

## Supported strategies

The Cloud Spanner adapter has only the deletion strategy.

## Strategy configuration options

* `:cache_tables` - When set to `true`, the list of tables to delete and the deletion orders will be
  read from the Cloud Spanner once, otherwise they will be read before each deletion. Defaults to
  `true`.

## Adapter configuration options

You need to specify instance and database, or to pass an instance of Spanner client.
If you're using ActiveRecord, you can use database name on ActiveRecord.
This adapter tries to get database configurations from ActiveRecord.

```ruby
# Specify instance and database with default credentials and project ID.
DatabaseCleaner[:spanner].db = {
  instance_id: "my-instance",
  database_id: "my-database",
}

# In addition, specify project ID and credentials.
DatabaseCleaner[:spanner].db = {
  credentials: "/path/to/key.json",
  project_id: "my-project",
  instance_id: "my-instance",
  database_id: "my-database",
}

# ActiveRecord database name
DatabaseCleaner[:spanner].db = "secondary"

# Spanner client object
DatabaseCleaner[:spanner].db =
  Google::Cloud::Spanner.new.client("my-instance", "my-database")
```

See [Spanner client reference](https://googleapis.dev/ruby/google-cloud-spanner/latest/Google/Cloud/Spanner.html#new-class_method) for more database options.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nownabe/database_cleaner-spanner. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nownabe/database_cleaner-spanner/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the DatabaseCleaner::Spanner project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nownabe/database_cleaner-spanner/blob/main/CODE_OF_CONDUCT.md).
