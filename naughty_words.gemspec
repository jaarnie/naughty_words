
# frozen_string_literal: true

require_relative "lib/naughty_words/version"

Gem::Specification.new do |spec|
  spec.name = "naughty_words"
  spec.version = NaughtyWords::VERSION
  spec.authors = ["John Arnold"]
  spec.email = ["johnadamarnold@gmail.com"]

  spec.summary = "Filter and check for profanity in strings"
  spec.description = "A Ruby gem to filter and check for profanity in strings, with support for custom word lists"
  spec.homepage = "https://github.com/jaarnie/naughty_words"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
    lib/**/*
    README.md
    LICENSE.txt
    CHANGELOG.md
  ])
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  
  # Optional dependencies for database integration
  spec.add_development_dependency "activerecord", ">= 5.0"
  spec.add_development_dependency "database_cleaner-active_record"
  spec.add_development_dependency "sqlite3"
end
