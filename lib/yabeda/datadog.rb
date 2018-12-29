# frozen_string_literal: true

require "yabeda"
require "yabeda/datadog/adapter"
require "yabeda/datadog/version"

module Yabeda
  # = Namespace for DataDog adapter
  module Datadog
    SECOND = 1
    COLLECT_INTERVAL = 60 * SECOND

    # TODO: consider to change too manual
    def self.start
      adapter = Yabeda::Datadog::Adapter.new
      Yabeda.register_adapter(:datadog, adapter)
      adapter
    end

    def self.start_exporter(collect_interval: COLLECT_INTERVAL)
      Thread.new do
        loop do
          Yabeda.collectors.each(&:call)
          sleep(collect_interval)
        end
      end
    end
  end
end
