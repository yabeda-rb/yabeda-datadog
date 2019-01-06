# frozen_string_literal: true

module Yabeda
  module Datadog
    # = Handle response from dogapi
    class ResponseHandler
      class << self
        def call(metric)
          Logging.instance.info "Sending #{metric.name} metric"
          response = yield
          Logging.instance.info "Response on #{metric.name}: #{handle(response)}"
          response
        end

        private

        def handle(response)
          if response.is_a? Array
            return response if response.count < 2
            raise response[1]["errors"].join(", ") if response[1].key?("errors")

            return "status: #{response[0]}, payload: #{response[1]}"
          end
          response
        end
      end
    end
  end
end
