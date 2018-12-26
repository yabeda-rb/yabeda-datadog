# frozen_string_literal: true

require "yabeda/datadog/units"

module Yabeda
  module Datadog
    # = Internal adapter representation of metrics
    class Metric
      def initialize(metric, type, overides = {})
        @metric = metric
        @type = type
        @overides = overides
      end

      # Datadog API argument
      def metadata
        {
          type: type,
          description: description,
          short_name: name,
          unit: unit,
          per_unit: per_unit,
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

      # Update metric metadata
      def update(api)
        api.update_metadata(name, metadata)
      end

      private

      attr_reader :metric, :type, :overides
    end
  end
end
