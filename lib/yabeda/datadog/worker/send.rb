# frozen_string_literal: true

module Yabeda
  module Datadog
    class Worker
      SEND = proc do |accumulated_payload|
        begin
          dogstatsd = ::Datadog::Statsd.new(
            Yabeda::Datadog.config.agent_host,
            Yabeda::Datadog.config.agent_port,
            **dogstatsd_options,
          )

          Logging.instance.debug("sending batch of #{accumulated_payload.size} metrics")
          begin
            dogstatsd.batch do |stats|
              accumulated_payload.each do |payload|
                metric = payload.fetch(:metric)
                value = payload.fetch(:value)
                tags = payload.fetch(:tags)

                stats.send(metric.type, metric.name, value, tags: tags)
              end
            end
          rescue StandardError => err
            Logging.instance.error("metric sending failed: #{err.message}")
          end
        ensure
          dogstatsd.close
        end
      end
      
      def self.dogstatsd_options
        @dogstatsd_options ||= dogstatsd_version >= Gem::Version.new("5.2") ? { single_thread: true } : {}
      end

      def self.dogstatsd_version
        return @dogstatsd_version if instance_variable_defined?(:@dogstatsd_version)
  
        @dogstatsd_version = (
          defined?(Datadog::Statsd::VERSION) &&
            Datadog::Statsd::VERSION &&
            Gem::Version.new(Datadog::Statsd::VERSION)
        ) || Gem.loaded_specs['dogstatsd-ruby']&.version
      end
    end
  end
end
