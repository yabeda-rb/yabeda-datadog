# frozen_string_literal: true

module Yabeda
  module Datadog
    # = The logic of working with Datadog tags
    class Tags
      def self.build(tags)
        tags.map { |key, value| "#{key}:#{value}" }
      end
    end
  end
end
