# frozen_string_literal: true

module Yabeda
  module Datadog
    class Worker
      DEFAULT_AGENT_HOST = "localhost"
      DEFAULT_AGENT_PORT = 8125

      SEND = proc do |accumulated_payload|
        dogstatsd = ::Datadog::Statsd.new(
          ENV.fetch("DATADOG_AGENT_HOST", DEFAULT_AGENT_HOST),
          ENV.fetch("DATADOG_AGENT_PORT", DEFAULT_AGENT_PORT),
        )

        dogstatsd.batch do |stats|
          accumulated_payload.each do |payload|
            metric = payload.fetch(:metric)
            value = payload.fetch(:value)
            tags = payload.fetch(:tags)

            Logger.instance.log_request metric do
              stats.send(metric.type, metric.name, value, tags: tags)
            end
          end
        end
      end
    end
  end
end
