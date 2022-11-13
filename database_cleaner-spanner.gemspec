# frozen_string_literal: true

require_relative "lib/database_cleaner/spanner/version"

Gem::Specification.new do |spec|
  spec.name = "database_cleaner-spanner"
  spec.version = DatabaseCleaner::Spanner::VERSION
  spec.authors = ["nownabe"]
  spec.email = ["nownabe@gmail.com"]

  spec.summary = "Strategies for cleaning tables on Cloud Spanner. Can be used to ensure a clean state for testing."
  spec.description = "Strategies for cleaning tables on Cloud Spanner. Can be used to ensure a clean state for testing."
  spec.homepage = "https://github.com/nownabe/database_cleaner-spanner"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "google-cloud-spanner", "~> 2.10"
  spec.add_dependency "database_cleaner-core", "~> 2.0.0"
end
