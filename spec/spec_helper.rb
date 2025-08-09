# frozen_string_literal: true

require "bundler/setup"
require "active_record"
require "sqlite3"
require "database_cleaner-active_record"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.define do
  create_table :naughty_words_lists do |t|
    t.string :word, null: false
    t.string :list_type, null: false
    t.string :category
    t.string :severity
    t.text :context
    t.string :added_by
    t.json :metadata, default: {}
    t.timestamps

    t.index [:word, :list_type], unique: true
    t.index :category
    t.index :severity
  end
end

require "naughty_words"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:active_record].clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner[:active_record].cleaning do
      example.run
    end
  end

  config.before(:each) do
    NaughtyWords::Config.reset!
  end
end
