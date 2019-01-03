# frozen_string_literal: true

module Yabeda
  module Datadog
    # = This error raised when no Datadog API key provided
    class ApiKeyError < StandardError
      def initialize(msg = "Datadog API key doesn't set")
        super
      end
    end

    # = This error raised when no Datadog application key provided
    class AppKeyError < StandardError
      def initialize(msg = "Datadog application key doesn't set")
        super
      end
    end
  end
end
