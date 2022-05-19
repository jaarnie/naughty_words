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
    
    # you can use in your own filter character by passing it in as an argument  ("*" is by default)
    NaughtyWords.filter(string: "hello asshole", replacement: "!")
    => "hello !!!!!!!"
```
Note: Current, this is comically easy to circumvent. String like "shitshitshit" will only filter out the first match, returning "*****shitshit". A fix is enroute.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaarnie/naughty_words. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jaarnie/naughty_words/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NaughtyWords project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/naughty_words/blob/master/CODE_OF_CONDUCT.md).
