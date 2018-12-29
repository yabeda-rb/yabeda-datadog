# frozen_string_literal: true

require "yabeda/datadog/worker"
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
      def initialize(worker: Worker.start)
        @worker = worker
      end

      def register_counter!(counter)
        metric = Metric.new(counter, "count")
        worker.enqueue(:register, metric: metric)
      end

      def perform_counter_increment!(counter, tags, increment)
        worker.enqueue(:send,
                       metric: Metric.new(counter, "count"),
                       value: increment,
                       tags: Tags.build(tags),)
      end

      def register_gauge!(gauge)
        metric = Metric.new(gauge, "gauge")
        worker.enqueue(:register, metric: metric)
      end

      def perform_gauge_set!(gauge, tags, value)
        worker.enqueue(:send,
                       metric: Metric.new(gauge, "gauge"),
                       value: value,
                       tags: Tags.build(tags),)
      end

      def register_histogram!(histogram)
        histogram_metrics(histogram).map do |historgam_sub_metric|
          worker.enqueue(:register, metric: historgam_sub_metric)
        end
      end

      def perform_histogram_measure!(historam, tags, value)
        worker.enqueue(:send,
                       metric: Metric.new(historam, "histogram"),
                       value: value,
                       tags: Tags.build(tags),)
      end

      def stop
        worker.stop
      end

      private

      attr_reader :worker

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
    end
  end
end
