# frozen_string_literal: true

require "yabeda/datadog/units"

module Yabeda
  module Datadog
    # = Internal adapter representation of metrics
    class Metric
      SECOND = 1
      DEFAULT_FLUSH_INTERVAL = SECOND * 10

      def initialize(metric, type, overides = {})
        @metric = metric
        @type = type
        @overides = overides
      end

      attr_reader :type

      # Datadog API argument
      def metadata
        {
          type: type,
          description: description,
          short_name: name,
          unit: unit,
          per_unit: per_unit,
          statsd_interval: statsd_interval,
        }
      end

      # Datadog API argument
      def name
        [metric.group, metric.name.to_s, overides[:name_sufix]].compact.join(".")
      end

      # Datadog API argument
      def description
        overides.fetch(:description, metric.comment)
      end

      # Datadog API argument
      def unit
        overides.fetch(:unit, Unit.find(metric.unit))
      end

      # Datadog API argument
      def per_unit
        overides.fetch(:per_unit, Unit.find(metric.per))
      end

      # Datadog API argument
      def statsd_interval
        DEFAULT_FLUSH_INTERVAL if type == "rate"
      end

      # Update metric metadata
      def update(api)
        api.update_metadata(name, metadata)
      end

      private

      attr_reader :metric, :overides

      class << self
        # Build Datadog histogram metrics from Yabeda histogram metric
        def histogram_metrics(historgram)
          [
            new(historgram, "gauge", name_sufix: "avg"),
            new(historgram, "gauge", name_sufix: "max"),
            new(historgram, "gauge", name_sufix: "min"),
            new(historgram, "gauge", name_sufix: "median"),
            new(historgram, "gauge", name_sufix: "95percentile", unit: nil, per_unit: nil),
            new(historgram, "rate", name_sufix: "count", unit: nil, per_unit: nil),
          ]
        end
      end
    end
  end
end
