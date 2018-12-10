# frozen_string_literal: true

require "dogapi"
require "yabeda/base_adapter"

module Yabeda
  module Datadog
    # DataDog adapter. Sends yabeda metrics as custom metrics to DataDog API.
    # https://docs.datadoghq.com/integrations/ruby/
    class Adapter < BaseAdapter
      def register_counter!(counter)
        metric = AdapterMetric.new(counter, "counter")
        dog.update_metadata(metric.name, metric.metadata)
      end

      def perform_counter_increment!(counter, tags, increment)
        metric = AdapterMetric.new(counter, "counter")
        tags[:type] = "counter"
        dog.emit_point(metric.name, increment, tags)
      end

      def register_gauge!(gauge)
        metric = AdapterMetric.new(gauge, "gauge")
        dog.update_metadata(metric.name, metric.metadata)
      end

      def perform_gauge_set!(gauge, tags, value)
        metric = AdapterMetric.new(gauge, "gauge")
        tags[:type] = "gauge"
        dog.emit_point(metric.name, value, tags)
      end

      private

      def dog
        ::Dogapi::Client.new(ENV["DATADOG_API_KEY"], ENV["DATADOG_APP_KEY"])
      end

      Yabeda.register_adapter(:datadog, new)
    end

    # Internal adapter representation of metrics
    class AdapterMetric
      def initialize(metric, type)
        @metric = metric
        @type = type
      end

      attr_reader :type

      def metadata
        {
          type: type,
          description: description,
          short_name: name,
          unit: unit,
          per_unit: per_unit,
        }
      end

      def name
        parts = ""
        parts += "#{metric.group}." if metric.group
        parts + metric.name.to_s
      end

      def description
        metric.comment
      end

      def unit
        metric.unit
      end

      def per_unit
        metric.per
      end

      private

      attr_reader :metric
    end
  end
end
