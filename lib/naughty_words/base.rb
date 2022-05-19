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
          string.gsub!(word, replacement * word.length)
        end

        string
      end

      private

      def blacklist_file
        txt_file = File.join(File.dirname(File.expand_path(__FILE__)), "config/en.txt")
        file = File.open(txt_file)

        @blacklist_file ||= file.readlines
      end
    end
  end
end
