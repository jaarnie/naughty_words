# frozen_string_literal: true

module NaughtyWords
  class Config
    class << self
      attr_accessor :word_boundaries, :use_built_in_lists, :minimum_severity
      attr_reader :allow_overrides, :deny_overrides

      def configure
        yield self
      end

      def reset!
        @word_boundaries = true
        @use_built_in_lists = true
        @minimum_severity = nil  # nil means check all severities
        @allow_overrides = []
        @deny_overrides = []
      end

      # override a word from the deny list to allow it
      def allow_word(word)
        word = word.to_s.strip
        return if word.empty?
        @allow_overrides << word.downcase
        @allow_overrides.uniq!
      end

      # override a word from the allow list to deny it
      def deny_word(word)
        word = word.to_s.strip
        return if word.empty?
        @deny_overrides << word.downcase
        @deny_overrides.uniq!
      end

      def remove_override(word)
        word = word.to_s.strip.downcase
        @allow_overrides.delete(word)
        @deny_overrides.delete(word)
      end
    end

    reset!
  end
end
