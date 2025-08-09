# frozen_string_literal: true

require_relative "config"

module NaughtyWords
  class Base
    class << self
      def profanity?(string:)
        validate_input!(string)
        normalized_string = normalize_string(string)

        return false if word_in_list?(normalized_string, Config.allow_overrides)
        return true if word_in_list?(normalized_string, Config.deny_overrides)

        return false if Config.use_built_in_lists && word_in_list?(normalized_string, allow_list_from_files)
        return false if word_in_list?(normalized_string, allow_list_from_db)

        return true if Config.use_built_in_lists && word_in_list?(normalized_string, deny_list_from_files)
        return true if word_in_list?(normalized_string, deny_list_from_db)

        false
      end

      def filter(string:, replacement: "*")
        validate_input!(string)
        validate_replacement!(replacement)
        result = string.dup

        denied_words = Config.deny_overrides.dup
        denied_words += deny_list_from_files if Config.use_built_in_lists
        denied_words += deny_list_from_db
        denied_words -= Config.allow_overrides # Remove any allowed overrides
        denied_words = denied_words.sort_by(&:length).reverse

        denied_words.each do |word|
          next if word.empty?
          result.gsub!(/#{Regexp.escape(word)}/i, replacement * word.length)
        end

        result
      end

      def show_list(list:, include_metadata: false)
        validate_list!(list)
        
        if include_metadata && defined?(WordList)
          WordList.where(list_type: list)
        else
          words = []
          words += (list == "deny" ? deny_list_from_files : allow_list_from_files) if Config.use_built_in_lists
          words += (list == "deny" ? deny_list_from_db : allow_list_from_db)
          words
        end
      end

      private

      def deny_list_from_files
        @deny_list_from_files ||= load_list(deny_list_path)
      end

      def allow_list_from_files
        @allow_list_from_files ||= load_list(allow_list_path)
      end

      def deny_list_from_db
        return [] unless db_table_available?
        query = WordList.deny_list

        if Config.minimum_severity
          severities = %w[high medium low]
          min_index = severities.index(Config.minimum_severity)
          return [] unless min_index
          allowed_severities = severities[0..min_index]
          query = query.where(severity: allowed_severities)
        end

        query.pluck(:word)
      rescue StandardError
        []
      end

      def allow_list_from_db
        return [] unless db_table_available?
        WordList.allow_list.pluck(:word)
      rescue StandardError
        []
      end

      def deny_list_path
        File.join(File.dirname(File.expand_path(__FILE__)), "config/deny_list.txt")
      end

      def allow_list_path
        File.join(File.dirname(File.expand_path(__FILE__)), "config/allow_list.txt")
      end

      def load_list(path)
        return [] unless Config.use_built_in_lists
        File.readlines(path, chomp: true).reject(&:empty?)
      rescue Errno::ENOENT
        raise Error, "List file not found: #{path}"
      rescue IOError => e
        raise Error, "Failed to read list: #{e.message}"
      end

      def word_in_list?(string, list)
        list.any? do |word|
          normalized_word = normalize_string(word)
          word_match?(string, normalized_word)
        end
      end

      def normalize_string(str)
        str.downcase
      end

      def word_pattern(word)
        escaped = Regexp.escape(word)
        if Config.word_boundaries
          /(?:^|[^a-zA-Z0-9])#{escaped}(?:$|[^a-zA-Z0-9])/i
        else
          /#{escaped}/i
        end
      end

      def word_match?(string, word)
        pattern = Config.word_boundaries ? 
          /(?:^|[^a-zA-Z0-9])#{Regexp.escape(word)}(?:$|[^a-zA-Z0-9])/i : 
          /#{Regexp.escape(word)}/i
        string.match?(pattern)
      end

      def validate_input!(string)
        raise ArgumentError, "Input string cannot be nil" if string.nil?
        raise ArgumentError, "Input string must be a String" unless string.is_a?(String)
      end

      def validate_replacement!(replacement)
        raise ArgumentError, "Replacement cannot be nil" if replacement.nil?
        raise ArgumentError, "Replacement must be a String" unless replacement.is_a?(String)
        raise ArgumentError, "Replacement cannot be empty" if replacement.empty?
      end

      def validate_list!(list)
        valid_lists = ["deny", "allow"]
        unless valid_lists.include?(list)
          raise ArgumentError, "Invalid list type. Must be one of: #{valid_lists.join(', ')}"
        end
      end

      def db_table_available?
        return false unless defined?(WordList) && defined?(ActiveRecord::Base)
        conn = ActiveRecord::Base.connection
        conn.data_source_exists?(WordList.table_name)
      rescue StandardError
        false
      end
    end
  end
end
