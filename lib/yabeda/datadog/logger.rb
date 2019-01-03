# frozen_string_literal: true

require 'logger'
require 'singleton'

module Yabeda
  module Datadog
    # = Perform loging
    class Logger
      include Singleton

      def initialize
        @logger = ::Logger.new(STDOUT)
      end

      def log_request(metric, &block)
        begin
          info "Sending #{metric.name} metric"
          result = handle_result(yield)
          info "Response on #{metric.name}: #{result}"
        rescue StandardError => e  
          fatal "Metric sending was failed: #{e.message}"
        end
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

      def handle_result(res)
        if res.is_a? Array
          return res if res.count < 2
          raise res[1]['errors'].join(', ') if res[1].has_key?('errors')
          return "status: #{res[0]}, payload: #{res[1]}"
        end
        res 
      end
    end
  end
end