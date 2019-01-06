# frozen_string_literal: true

module Yabeda
  module Datadog
    class Worker
      REGISTER = proc do |accumulated_payload|
        dogapi = ::Dogapi::Client.new(Yabeda::Datadog.config.api_key, Yabeda::Datadog.config.app_key)

        accumulated_payload.each do |payload|
          metric = payload.fetch(:metric)
          metric.update(dogapi)
        end
      end
    end
  end
end
