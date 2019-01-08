# frozen_string_literal: true

module Yabeda
  module Datadog
    class Worker
      SEND = proc do |accumulated_payload|
        dogstatsd = ::Datadog::Statsd.new(
          Yabeda::Datadog.config.agent_host,
          Yabeda::Datadog.config.agent_port,
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
      end
    end
  end
end
