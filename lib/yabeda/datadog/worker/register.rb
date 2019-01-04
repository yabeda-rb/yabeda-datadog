# frozen_string_literal: true

module Yabeda
  module Datadog
    class Worker
      REGISTER = proc do |accumulated_payload|
        dogapi = ::Dogapi::Client.new(ENV["DATADOG_API_KEY"], ENV["DATADOG_APP_KEY"])

        accumulated_payload.each do |payload|
          metric = payload.fetch(:metric)

          begin
            Logging.instance.log_request metric do
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
