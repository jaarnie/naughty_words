## [Unreleased]

## [1.0.2] - 2026-06-30

### Fixed
- `filter` now respects file and DB allow lists, not just runtime overrides — a word in the allow list is no longer masked by `filter` even if it appears verbatim in a deny list
- `show_list(include_metadata: true)` no longer raises `NoMethodError` when ActiveRecord is not loaded
- Built-in word lists are now always loaded from file on first access; toggling `use_built_in_lists` off and back on no longer returns stale empty lists
- Migration template now uses `ActiveRecord::Migration.current_version` instead of a hardcoded `[7.0]`, fixing Rails 6/6.1 compatibility

## [0.1.0] - 2022-05-18

- Initial release
