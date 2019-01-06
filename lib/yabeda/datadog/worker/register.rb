# frozen_string_literal: true

module Yabeda
  module Datadog
    class Worker
      REGISTER = proc do |accumulated_payload|
        dogapi = ::Dogapi::Client.new(Yabeda::Datadog.config.api_key, Yabeda::Datadog.config.app_key)

        accumulated_payload.each do |payload|
          metric = payload.fetch(:metric)

          begin
            ResponseHandler.call(metric) do
              metric.update(dogapi)
            end
          rescue StandardError => e
            Logging.instance.fatal "Metric sending failed: #{e.message}"
          end
        end
      end
    end
  end
end
