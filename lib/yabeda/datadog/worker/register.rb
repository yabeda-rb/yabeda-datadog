# frozen_string_literal: true

module Yabeda
  module Datadog
    class Worker
      REGISTER = proc do |accumulated_payload|
        dogapi = ::Dogapi::Client.new(ENV["DATADOG_API_KEY"], ENV["DATADOG_APP_KEY"])

        accumulated_payload.each do |payload|
          metric = payload.fetch(:metric)
          metric.update(dogapi)
        end
      end
    end
  end
end
