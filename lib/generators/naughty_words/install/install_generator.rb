
# frozen_string_literal: true

module NaughtyWords
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(path)
        next_migration_number = current_migration_number(path) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def copy_migrations
        migration_template(
          "create_naughty_words_lists.rb",
          "db/migrate/create_naughty_words_lists.rb"
        )
      end

      def copy_models
        template "word_list.rb", "app/models/naughty_words/word_list.rb"
      end

      def copy_initializer
        template "initializer.rb", "config/initializers/naughty_words.rb"
      end
    end
  end
end
