# frozen_string_literal: true

require "logger"
require "singleton"

module Yabeda
  module Datadog
    # = Perform loging
    class Logging
      include Singleton

      def initialize
        @logger = Logger.new(STDOUT)
      end

      def log_request(metric)
        info "Sending #{metric.name} metric"
        response = yield
        info "Response on #{metric.name}: #{handle_response(response)}"
        response
      rescue StandardError => e
        fatal "Metric sending was failed: #{e.message}"
      end

      def warn(message)
        @logger.warn message
      end

      def info(message)
        @logger.info message
      end

      def debug(message)
        @logger.debug message
      end

      def fatal(message)
        @logger.fatal message
      end

      def error(message)
        @logger.error message
      end

      def level=(level)
        @logger.level = level
      end

      private

      def handle_response(response)
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
