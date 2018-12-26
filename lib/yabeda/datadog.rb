# frozen_string_literal: true

require "yabeda"
require "yabeda/datadog/adapter"
require "yabeda/datadog/version"

module Yabeda
  # = Namespace for DataDog adapter
  module Datadog
    SECOND = 1
    DEFAULT_COLLECT_INTERVAL = 60 * SECOND

    def self.start_exporter(collect_interval: DEFAULT_COLLECT_INTERVAL)
      Thread.new do
        loop do
          Yabeda.collectors.each(&:call)
          sleep(collect_interval)
        end
      end
    end
  end
end
