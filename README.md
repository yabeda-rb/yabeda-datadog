# Yabeda Datadog adapter

[Yabeda](https://github.com/yabeda-rb/yabeda) adapter for easy exporting collected custom metrics from your application to the Datadog API.


## Installation

This adapter send metrics to [Datadog API](https://docs.datadoghq.com/api/?lang=ruby) and requires to have and Datadog account with API key. You can obtain your Datadog API key in [Datadog dashboard](https://app.datadoghq.com/account/settings#api). For more information refer to [API documentation](https://docs.datadoghq.com/api/?lang=ruby#authentication).

Add line to your application's Gemfile:

```ruby
gem 'yabeda-datadog'
```

And then execute:

    $ bundle

## Usage

Require this adapter before Yabeda configuration:

```ruby
require "yabeda/datadog"
```

Refer to [Yabeda documentation](https://github.com/yabeda-rb/yabeda) for instruction how to configure and use Yabeda.

Refer to [Datadog metrics documentation](https://docs.datadoghq.com/graphing/metrics/) for working with your metrics in Datadog dashboard.

Please note that configuring Yabeda you have to use Datadog units. Refer to [Datadog unit for metrics documentation](https://docs.datadoghq.com/developers/metrics/#units).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shvetsovdm/yabeda-datadog.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
