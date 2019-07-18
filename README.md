# ActionCable Bunny

🚧 RabbitMQ adabter for ActionCable using Bunny gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'action-cable-bunny'
```

And then execute:

    $ bundle

## Usage

```yaml
# config/cable.yml
bunny: &bunny
  adapter: bunny
production: *bunny
development: *bunny

```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kylewelsby/action-cable-bunny. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kylewelsby/action-cable-bynny/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](./LICENSE).
