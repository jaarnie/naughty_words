# frozen_string_literal: true

require_relative "naughty_words/version"
require_relative "naughty_words/config"
require_relative "naughty_words/word_list"
require_relative "naughty_words/base"

module NaughtyWords
  class Error < StandardError; end

  def self.configure
    Config.configure { |config| yield(config) }
  end

  class << self
    def check(string:)
      Base.profanity?(string: string)
    end

    def filter(string:, replacement: "*")
      Base.filter(string: string, replacement: replacement)
    end

    def show_list(list:, include_metadata: false)
      Base.show_list(list: list, include_metadata: include_metadata)
    end
  end
end
