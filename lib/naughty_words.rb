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
  end
end
