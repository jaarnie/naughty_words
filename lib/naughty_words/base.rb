# frozen_string_literal: true

module NaughtyWords
  class Base
    class << self
      def profanity?(string:)
        allow_list_array.each do |line|
          return false if string.include?(line)
        end

        deny_list_array.each do |line|
          return true if string.include?(line)
        end

        false
      end

      def filter(string:, replacement:)
        # TODO: Fix filtering full words ending with 'ing' and repeated words such as 'fuckfuckfuck'
        deny_list_array.each do |line|
          word = line
          string.gsub!(word, replacement * word.length)
        end

        string
      end

      def add_to_list(list:, string:)
        File.open(send(list), "a+") do |file|
          file.puts(string)
        end
      end

      def show_list(list:)
        if list == "deny"
          deny_list_array
        else
          allow_list_array
        end
      end

      private

      def deny_list_array
        file = File.open(File.join(File.dirname(File.expand_path(__FILE__)), "config/deny_list.txt"))

        @deny_list_array ||= File.readlines(file, chomp: true)
      end

      def allow_list_array
        file = File.open(File.join(File.dirname(File.expand_path(__FILE__)), "config/allow_list.txt"))

        @allow_list_array ||= File.readlines(file, chomp: true)
      end
    end
  end
end
