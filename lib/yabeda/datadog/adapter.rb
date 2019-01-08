# frozen_string_literal: true

require "yabeda/datadog/worker"
require "yabeda/datadog/metric"
require "yabeda/datadog/tags"
require "yabeda/base_adapter"
require "datadog/statsd"
require "dogapi"

module Yabeda
  module Datadog
    # = DataDog adapter.
    #
    # Sends yabeda metrics as custom metrics to DataDog.
    # https://docs.datadoghq.com/integrations/ruby/
    class Adapter < BaseAdapter
      def initialize(worker:)
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
        Metric.histogram_metrics(histogram).map do |historgam_sub_metric|
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
    end
  end
end
