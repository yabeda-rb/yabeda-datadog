# frozen_string_literal: true

require "logger"
require "singleton"

module Yabeda
  module Datadog
    # = Perform loging
    class Logging
      include Singleton

      def initialize
        @logger = Logger.new(STDOUT,
                             level: Yabeda::Datadog.config.log_level,
                             progname: "yabeda_datadog",)
      end

      def warn(message)
        @logger.warn(message)
      end

      def info(message)
        @logger.info(message)
      end

      def debug(message)
        @logger.debug(message)
      end

      def fatal(message)
        @logger.fatal(message)
      end

      def error(message)
        @logger.error(message)
      end

      def level=(level)
        @logger.level = level
      end
    end
  end
end
