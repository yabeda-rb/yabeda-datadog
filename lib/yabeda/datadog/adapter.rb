# frozen_string_literal: true

require "yabeda/datadog/metric"
require "yabeda/datadog/tags"
require "yabeda/base_adapter"
require "datadog/statsd"
require "dogapi"

module Yabeda
  module Datadog
    DEFAULT_AGENT_HOST = "localhost"
    DEFAULT_AGENT_PORT = 8125

    # = DataDog adapter.
    #
    # Sends yabeda metrics as custom metrics to DataDog API.
    # https://docs.datadoghq.com/integrations/ruby/
    class Adapter < BaseAdapter
      def register_counter!(counter)
        metric = Metric.new(counter, "counter")
        Thread.new { metric.update(dogapi) }
      end

      def perform_counter_increment!(counter, tags, increment)
        metric = Metric.new(counter, "counter")
        dogstatsd.count(metric.name, increment, tags: Tags.build(tags))
      end

      def register_gauge!(gauge)
        metric = Metric.new(gauge, "gauge")
        Thread.new { metric.update(dogapi) }
      end

      def perform_gauge_set!(gauge, tags, value)
        metric = Metric.new(gauge, "gauge")
        dogstatsd.gauge(metric.name, value, tags: Tags.build(tags))
      end

      def register_histogram!(histogram)
        # sending many requests in separate threads
        # cause rejections by Datadog API
        Thread.new do
          histogram_metrics(histogram).map do |historgam_sub_metric|
            historgam_sub_metric.update(dogapi)
          end
        end
      end

      def perform_histogram_measure!(historam, tags, value)
        metric = Metric.new(historam, "histogram")
        dogstatsd.histogram(metric.name, value, tags: Tags.build(tags))
      end

      private

      def dogstatsd
        # consider memoization here
        ::Datadog::Statsd.new(
          ENV.fetch("DATADOG_AGENT_HOST", DEFAULT_AGENT_HOST),
          ENV.fetch("DATADOG_AGENT_PORT", DEFAULT_AGENT_PORT),
        )
      end

      def dogapi
        # consider memoization here
        ::Dogapi::Client.new(ENV["DATADOG_API_KEY"], ENV["DATADOG_APP_KEY"])
      end

      def histogram_metrics(historgram)
        [
          Metric.new(historgram, "gauge", name_sufix: "avg"),
          Metric.new(historgram, "gauge", name_sufix: "max"),
          Metric.new(historgram, "gauge", name_sufix: "min"),
          Metric.new(historgram, "gauge", name_sufix: "median"),
          Metric.new(historgram, "gauge", name_sufix: "95percentile", unit: nil, per_unit: nil),
          Metric.new(historgram, "rate", name_sufix: "count", unit: nil, per_unit: nil),
        ]
      end

      Yabeda.register_adapter(:datadog, new)
    end
  end
end
