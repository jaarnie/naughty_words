# NaughtyWords

A super basic gem to check if a string has profanites. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'naughty_words'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install naughty_words

## Usage

**Check if a string includes a profanity**
The `check` method takes in a `string:` argument and will return a boolean.
```ruby
    NaughtyWords.check(string: "ass")
    => true

    NaughtyWords.check(string: "hello world")
    => false

    NaughtyWords.check(string: "hello asshole")
    => true
```

**Filter out words**
The `filter` method takes a `string:` argument and an optional `replacement:` argument.

``` ruby
    # passing a string with no profanity will return the string
    NaughtyWords.filter(string: "hello world")
    => "hello world"
    
    # passing a string with profanities will return the string with the profanity filtered out
    NaughtyWords.filter(string: "hello asshole")
    => "hello *******"
    
    # you can filter out consecutive naughty words
    NaughtyWords.filter(string: "shitshitshityeah")
    => "************yeah"
    
    # you can use in your own filter character by passing it in as an argument  ("*" is by default)
    NaughtyWords.filter(string: "hello asshole", replacement: "!")
    => "hello !!!!!!!"
```

### Validating in Rails example
We can use a custom validator in our User model to make sure a user cannot sign up with a username containing profanities in tandem with our normal `validates` methods.

```ruby
# app/models/user.rb

validates :username, uniqueness: true, presence: true # basic username validation 
validate :username_profanity_check # our custom validator

...

def username_profanity_check
    errors.add(:username, "contains profanity") if NaughtyWords.check(string: username)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaarnie/naughty_words. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jaarnie/naughty_words/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NaughtyWords project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/naughty_words/blob/master/CODE_OF_CONDUCT.md).
