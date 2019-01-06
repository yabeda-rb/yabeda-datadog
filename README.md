# Yabeda Datadog adapter

[Yabeda](https://github.com/yabeda-rb/yabeda) adapter for easy exporting collected custom metrics from your application to the Datadog API.

## Prerequisites

Have an instance of Datadog agent and dogstats-d running. For other installation options of Datadog agent please refer to [Datadog agent documentation](https://docs.datadoghq.com/agent/).

## Installation

Add to your application's Gemfile:

```ruby
gem 'yabeda-datadog'
```

And then execute:

    $ bundle

## Usage

Configure Yabeda metrics. Refer to [Yabeda documentation](https://github.com/yabeda-rb/yabeda) for instruction on how to configure and use Yabeda metrics.

Please note when configuring Yabeda you have to use Datadog units. Refer to [Datadog unit for metrics documentation](https://docs.datadoghq.com/developers/metrics/#units).
If a unit of a metric is not supported by Datadog, this unit will not be automatically updated. But you always have the ability to update it manually in Datadog metrics dashboard or by calling API by yourself.

Refer to [Datadog metrics documentation](https://docs.datadoghq.com/graphing/metrics/) for working with your metrics in Datadog dashboard.

Start the adapter with the command:

```ruby
Yabeda::Datadog.start
```

You have to set your `DATADOG_API_KEY` and `DATADOG_APP_KEY` as environment variables. You can obtain your Datadog API keys in [Datadog dashboard](https://app.datadoghq.com/account/settings#api).

You may specify `DATADOG_AGENT_HOST` and/or `DATADOG_AGENT_PORT` environment variables if your Datadog agent is run not in the same host as an app/code that you collection metrics.

To star collecting Yabeda collect blocks (aka collectors) run the command:

```ruby
Yabeda::Datadog.start_exporter

# optionaly you can pass collect_interval argument

ten_seconds = 10
Yabeda::Datadog.start_exporter(collect_interval: ten_seconds)
```

### Limitations

On the first run of your application no metrics metadata will be updated. This is happening because metrics have not yet been collected, thus not been created, and there is nothing to update.

### Example

[yabeda-datadog-sidekiq-example](https://github.com/shvetsovdm/yabeda-datadog-sidekiq-example)

### Alternatives

Using [Prometheus support for Datadog Agent 6](https://www.datadoghq.com/blog/monitor-prometheus-metrics/) with [yabeda-prometheus](https://github.com/yabeda-rb/yabeda-prometheus).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

You can run a dogstats-d instance in a docker container with the following command:

    $ bin/dev

Beware that the agent will collect metrics (a lot) from docker itself and your OS and  all launched docker containers. You have to provide `DD_API_KEY` in `.datadog-agent.env` file. You can put additional environment variable for Datadog agent container into this file

Example of `.datadog-agent.env` file:

```
DD_API_KEY=<your Datadog API key>
DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true
DD_HOSTNAME=my-development-computer
```

To install this gem onto your local machine, run:

    $ bundle exec rake install

To release a new version, update the version number in `version.rb`, and then run:

    $ bundle exec rake release

Which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/shvetsovdm/yabeda-datadog](https://github.com/shvetsovdm/yabeda-datadog).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
