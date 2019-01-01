# frozen_string_literal: true
	
module Yabeda
  module Datadog
    class ApiKeyError < StandardError
      def initialize(msg="DataDog API key doesn't set")
        super
      end
    end

    class AppKeyError < StandardError
      def initialize(msg="DataDog application key doesn't set")
        super
      end
    end
  end
end
