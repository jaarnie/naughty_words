# frozen_string_literal: true

require "active_record" if defined?(ActiveRecord)

module NaughtyWords
  if defined?(ActiveRecord::Base)
    class WordList < ActiveRecord::Base
      self.table_name = "naughty_words_lists"

      validates :word, presence: true
      validates :list_type, presence: true, inclusion: { in: %w[deny allow] }
      validates :word, uniqueness: { scope: :list_type }
      validates :severity, inclusion: { in: %w[high medium low], allow_nil: true }

      scope :deny_list, -> { where(list_type: "deny") }
      scope :allow_list, -> { where(list_type: "allow") }
      scope :by_category, ->(category) { where(category: category) }
      scope :by_severity, ->(severity) { where(severity: severity) }
      scope :added_by, ->(user) { where(added_by: user) }

      before_save :normalize_word

      private

      def normalize_word
        self.word = word.strip.downcase if word.present?
      end
    end
  else
    class WordList
      def self.deny_list
        []
      end

      def self.allow_list
        []
      end
    end
  end
end 
