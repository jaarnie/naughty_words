# frozen_string_literal: true

require_relative "naughty_words/version"
require "naughty_words/base"

module NaughtyWords
  class Error < StandardError; end
  class << self
    def check(string:)
      Base.profanity?(string: string)
    end

    def filter(string:, replacement: "*")
      Base.filter(string: string, replacement: replacement)
    end

    def add_to_deny_list(string:)
      Base.add_to_list(list: "deny_list_file", string: string)
    end

    def add_to_allow_list(string:)
      Base.add_to_list(list: "allow_list_file", string: string)
    end

    def show_list(list:)
      Base.show_list(list: list)
    end
  end
end
