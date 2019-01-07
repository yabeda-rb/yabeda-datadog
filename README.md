# Yabeda Datadog adapter

[Yabeda](https://github.com/yabeda-rb/yabeda) adapter for easy exporting collected custom metrics from your application to the Datadog API.

## Prerequisites

Have an instance of Datadog agent and dogstats-d running. For installation options of Datadog agent please refer to [Datadog agent documentation](https://docs.datadoghq.com/agent/).

## Installation

Add to your application's Gemfile:

```ruby
gem 'yabeda-datadog'
```

And then execute:

    $ bundle

## Usage

### Define metrics

Define Yabeda metrics to collect. Refer to [Yabeda documentation](https://github.com/yabeda-rb/yabeda) for instruction on how to configure and use Yabeda metrics.

Please note when configuring Yabeda you have to use [Datadog units](https://docs.datadoghq.com/developers/metrics/#units).
If a unit of a metric is not supported by Datadog, unit information will not be submitted to Datadog. However, the rest of the metric information will be updated.
You always have the ability to update it manually in Datadog metrics dashboard or by calling API by yourself.

Refer to [Datadog metrics documentation](https://docs.datadoghq.com/graphing/metrics/) for working with your metrics in Datadog dashboard.

### Configure the adapter

You can configure with either `APP_ROOT/config/yabeda_datadog.yml` file or with environment variables.
Rails 5.1 users able to use encrypted rails secrets `Rails.application.secrets.yabeda_datadog.*`.

Example of `yabeda_datadog.yml` file:

```yaml
# required
api_key: <your Datadog API key>
app_key: <your Datadog App key>

# optional, default values used as an example
# how many queued metrics metrics sends in batches
batch_size: 10
# how many metrics you can queue for sending
queue_size: 1000
# threads to sends enqueued metrics
num_threads: 2
# Datadog agent host and port
agent_host: localhost
agent_port: 8125
```

Example of environment variables:

```shell
# required
YABEDA_DATADOG_API_KEY=<your Datadog API key>
YABEDA_DATADOG_APP_KEY=<your Datadog App key>

# optional, default values used as an example
# how many queued metrics metrics sends in batches
YABEDA_DATADOG_BATCH_SIZE=10
# how many metrics you can queue for sending
YABEDA_DATADOG_QUEUE_SIZE=1000
# threads to sends enqueued metrics
YABEDA_DATADOG_NUM_THREADS=2
# Datadog agent host and port
YABEDA_DATADOG_AGENT_HOST=localhost
YABEDA_DATADOG_AGENT_PORT=8125
```

You can obtain your Datadog API keys in [Datadog dashboard](https://app.datadoghq.com/account/settings#api).

Please note, when filling the queue (queue size option), your application will be blocked by waiting for a place in the queue.

You may specify `DATADOG_AGENT_HOST` and/or `DATADOG_AGENT_PORT` environment variables if your Datadog agent is running not on the same host as an app/code that collects metrics.

### Start the adapter

To start collecting and sending your metrics to Datadog agent run:

```ruby
Yabeda::Datadog.start
```

To star collecting Yabeda collect blocks (aka collectors) run the command:

```ruby
Yabeda::Datadog.start_exporter

# optionaly you can pass collect_interval argument

TEN_SECONDS = 10
Yabeda::Datadog.start_exporter(collect_interval: TEN_SECONDS)
```

### Limitations

On the first run of your application no metrics metadata will be updated. This is happening because metrics have not yet been collected, thus not been created, and there is nothing to update.

### Example

[yabeda-datadog-sidekiq-example](https://github.com/shvetsovdm/yabeda-datadog-sidekiq-example)

### Alternatives

Using [Prometheus support for Datadog Agent 6](https://www.datadoghq.com/blog/monitor-prometheus-metrics/) with [yabeda-prometheus](https://github.com/yabeda-rb/yabeda-prometheus).

## Contributing

Please see [CONTRIBUTING guide](/CONTRIBUTING.md).

Bug reports and pull requests are welcome on GitHub at [https://github.com/shvetsovdm/yabeda-datadog](https://github.com/shvetsovdm/yabeda-datadog).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
