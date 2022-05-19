# frozen_string_literal: true

module NaughtyWords
  class Base
    class << self
      def profanity?(string:)
        blacklist_file.each do |line|
          return true if string.include?(line.chomp)
        end

        false
      end

      def filter(string:, replacement:)
        # TODO: Fix filtering full words ending with 'ing' and repeated words such as 'fuckfuckfuck'
        blacklist_file.each do |line|
          word = line.chomp
          string.sub!(word, replacement * word.length)
        end

        string
      end

      private

      def blacklist_file
        File.open("./config/en.txt") do |file|
          @blacklist_file ||= file.readlines
        end
      end
    end
  end
end
