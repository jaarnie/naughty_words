# NaughtyWords

A Ruby gem for filtering profanity from text. Features include:
- Built-in deny and allow lists
- Database integration for custom word lists
- Runtime word overrides
- Word boundary matching (for checks)
- Case insensitive matching
- Optional severity-based filtering for DB deny words

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'naughty_words'
```

And then execute:
```bash
bundle install
```

Or install it yourself as:
```bash
gem install naughty_words
```

## Basic Usage

```ruby
# Check if a string contains profanity
NaughtyWords.check(string: "hello world")  # => false
NaughtyWords.check(string: "fuck this")    # => true

# Filter profanity from a string
NaughtyWords.filter(string: "hello world")  # => "hello world"
NaughtyWords.filter(string: "fuck this")    # => "**** this"

# Use custom replacement character
NaughtyWords.filter(string: "fuck this", replacement: "@")  # => "@@@@ this"
```

## Configuration

Configure the gem's behavior:

```ruby
NaughtyWords.configure do |config|
  # Match whole words only (default: true)
  # When true: "fuck" matches "fuck" but not "fuckthis"
  # When false: "fuck" matches both "fuck" and "fuckthis"
  config.word_boundaries = true

  # Use built-in word lists (default: true)
  # Set to false to use only database or runtime overrides
  config.use_built_in_lists = true

  # Only consider DB deny words at or above this severity (optional)
  # One of: "high", "medium", "low". nil means all severities.
  config.minimum_severity = nil
end

# For tests or to return to defaults
NaughtyWords::Config.reset!
```

## Database Integration

The gem can use a database (ActiveRecord) to store custom word lists.

1) Install migration, model, and initializer:
```bash
rails generate naughty_words:install
```

This adds:
- db/migrate/create_naughty_words_lists.rb
- app/models/naughty_words/word_list.rb
- config/initializers/naughty_words.rb

2) Add optional columns if you need them

If you plan to use `category`, `severity` ("high" | "medium" | "low"), or `metadata` (JSON), add these columns to your migration before running it. Example:

```ruby
change_table :naughty_words_lists do |t|
  t.string :category        # optional
  t.string :severity        # optional, one of "high", "medium", "low"
  t.json   :metadata, default: {}  # optional
end
```

Then run:
```bash
rails db:migrate
```

3) Add words to your lists:
```ruby
# Basic usage
NaughtyWords::WordList.create!(word: "badword", list_type: "deny")
NaughtyWords::WordList.create!(word: "scunthorpe", list_type: "allow")

# With optional metadata (requires columns above)
NaughtyWords::WordList.create!(
  word: "badword",
  list_type: "deny",
  context: "Added due to user complaints",
  added_by: "john@example.com",
  severity: "high",
  category: "insults",
  metadata: { reported_by: "forum_moderator" }
)
```

4) View your lists:
```ruby
# Get just the words
NaughtyWords.show_list(list: "deny")
# => ["badword", "otherbadword", ...]

# Get full records with metadata
records = NaughtyWords.show_list(list: "deny", include_metadata: true)
records.first
# => #<NaughtyWords::WordList ... word: "badword", list_type: "deny", ...>

# Query with metadata (if you use it)
words = NaughtyWords::WordList.where(list_type: "deny")
                             .where(added_by: "john@example.com")
                             .where("metadata->>'category' = ?", "insults")
```

### View only the built-in default lists

If you want to see the gem's built-in lists (ignoring anything in your database):

```ruby
# Ensure built-ins are enabled (default: true)
NaughtyWords::Config.use_built_in_lists = true

# If you have no DB entries, this already shows the built-ins
NaughtyWords.show_list(list: "deny")   # => built-in deny words
NaughtyWords.show_list(list: "allow")  # => built-in allow words

# If you DO have DB entries and want to isolate the built-ins only:
built_in_deny  = NaughtyWords.show_list(list: "deny")  - NaughtyWords::WordList.deny_list.pluck(:word)
built_in_allow = NaughtyWords.show_list(list: "allow") - NaughtyWords::WordList.allow_list.pluck(:word)

built_in_deny.first(10)
```

5) Severity-based checks from DB (optional)
```ruby
# Only consider DB deny words at or above "medium"
NaughtyWords.configure { |c| c.minimum_severity = "medium" }

# Or query explicitly via scopes
NaughtyWords::WordList.by_severity("high").pluck(:word)
NaughtyWords::WordList.by_severity("high").by_category("insults").pluck(:word)
```

## Runtime Overrides

Override word lists temporarily during runtime:

```ruby
# Allow a word that's normally blocked
NaughtyWords::Config.allow_word("someword")

# Block a word that's normally allowed
NaughtyWords::Config.deny_word("otherword")

# Remove an override
NaughtyWords::Config.remove_override("someword")
```

Overrides:
- Take precedence over both built-in lists and database lists
- Are case insensitive
- Reset when your application restarts
- Perfect for testing or temporary customizations

## How It Works

1) When checking/filtering text:
   - First checks runtime overrides
   - Then checks built-in lists (if enabled)
   - Then checks database lists (if present)

2) Word matching is:
   - Always case insensitive
   - Configurable for word boundaries (affects checks)
   - Handles special characters and spaces

3) Priority order:
   1. Runtime overrides (highest)
   2. Built-in lists
   3. Database lists (lowest)

4) Filtering details:
   - Replacement proceeds longest-to-shortest denied words.
   - Filtering masks any occurrence of denied words (case-insensitive), regardless of `word_boundaries`.
   - Example: with boundaries on, `check` may pass for “scunthorpe”, but if “cunt” is denied, `filter` will still mask “cunt” inside “scunthorpe”.

## Default list philosophy

The built-in deny list is intentionally minimal and neutral by default.

- Focuses on single-word profanities and slurs only
- Avoids medical/sexual terms and general sexual content
- Avoids multi-word phrases and “moral policing”

Customize to your community via the database layer:
- Add phrases (e.g., “eat my ass”) to `naughty_words_lists` with `category`/`severity`
- Use `minimum_severity` to tune strictness globally
- Use runtime overrides for temporary exceptions

## Examples

### Basic Filtering
```ruby
# Simple profanity check
NaughtyWords.check(string: "hello world")  # => false
NaughtyWords.check(string: "fuck this")    # => true

# Filter with default replacement (*)
NaughtyWords.filter(string: "fuck this")  # => "**** this"

# Custom replacement character
NaughtyWords.filter(string: "fuck this", replacement: "@")  # => "@@@@ this"
```

### Word Boundaries
```ruby
# With word_boundaries = true (default)
NaughtyWords.check(string: "fuck")      # => true
NaughtyWords.check(string: "fuckthis")  # => false

# With word_boundaries = false
NaughtyWords.configure { |c| c.word_boundaries = false }
NaughtyWords.check(string: "fuckthis")  # => true
```

### Database Integration
```ruby
# Add custom words
NaughtyWords::WordList.create!(word: "badword", list_type: "deny")
NaughtyWords::WordList.create!(word: "goodword", list_type: "allow")

# View lists with metadata
NaughtyWords.show_list(list: "deny", include_metadata: true)
# => [#<NaughtyWords::WordList id: 1, word: "badword", list_type: "deny", created_at: ...>]
```

### Runtime Overrides
```ruby
# Override the built-in lists
NaughtyWords::Config.allow_word("fuck")  # Allow this word
NaughtyWords.check(string: "fuck")       # => false

# Multiple overrides
NaughtyWords::Config.allow_word("fuck")
NaughtyWords::Config.allow_word("shit")
NaughtyWords.filter(string: "fuck this shit")  # => "fuck this shit"

# Remove overrides
NaughtyWords::Config.remove_override("fuck")
NaughtyWords.check(string: "fuck")  # => true (back to default)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at `https://github.com/jaarnie/naughty_words`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
