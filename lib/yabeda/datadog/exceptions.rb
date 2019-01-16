# frozen_string_literal: true

module Yabeda
  module Datadog
    class ConfigError < StandardError; end
    # = This error raised when no Datadog API key provided
    class ApiKeyError < ConfigError
      def initialize(msg = "Datadog API key is missing")
        super
      end
    end

    # = This error raised when no Datadog application key provided
    class AppKeyError < ConfigError
      def initialize(msg = "Datadog application key is missing")
        super
      end
    end
  end
end
