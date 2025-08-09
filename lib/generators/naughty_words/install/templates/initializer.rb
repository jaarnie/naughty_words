# frozen_string_literal: true

NaughtyWords.configure do |config|
  # Match whole words only (default: true). Set false to allow substrings.
  config.word_boundaries = true

  # Include built-in allow/deny lists (default: true).
  config.use_built_in_lists = true

  # Optional: only consider DB deny words at or above this severity.
  # One of: "high", "medium", "low"; nil means all severities.
  config.minimum_severity = nil
end
