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
        enqueue_register(Metric.new(counter, "count"))
      end

      def perform_counter_increment!(counter, tags, increment)
        metric = Metric.new(counter, "count")
        tags = Tags.build(tags)
        enqueue_send(metric, increment, tags)
      end

      def register_gauge!(gauge)
        enqueue_register(Metric.new(gauge, "gauge"))
      end

      def perform_gauge_set!(gauge, tags, value)
        metric = Metric.new(gauge, "gauge")
        tags = Tags.build(tags)
        enqueue_send(metric, value, tags)
      end

      def register_histogram!(histogram)
        histogram_metrics(histogram).map do |historgam_sub_metric|
          enqueue_register(historgam_sub_metric)
        end
      end

      def perform_histogram_measure!(historam, tags, value)
        metric = Metric.new(historam, "histogram")
        tags = Tags.build(tags)
        enqueue_send(metric, value, tags)
      end

      def stop
        worker.stop
      end

      private

      attr_reader :worker

      def enqueue_register(metric)
        worker.enqueue(:REGISTER, metric: metric)
      end

      def enqueue_send(metric, value, tags)
        worker.enqueue(:SEND, metric: metric, value: value, tags: tags)
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
    end
  end
end
