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
          @logger.info "Sending #{metric.name} metric"
          result = handle_result(yield)
          @logger.info "Response on #{metric.name}: #{result}"
        rescue StandardError => e  
          @logger.fatal "Metric sending was failed: #{e.message}"
        end
      end

      def write(message)
        @logger.info message
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
