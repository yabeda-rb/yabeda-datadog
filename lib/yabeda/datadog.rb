# frozen_string_literal: true

require "yabeda"
require "yabeda/datadog/adapter"
require "yabeda/datadog/version"
require "yabeda/datadog/exceptions"
require "yabeda/datadog/logging"

module Yabeda
  # = Namespace for DataDog adapter
  module Datadog
    SECOND = 1
    COLLECT_INTERVAL = 60 * SECOND

    def self.start
      raise ApiKeyError unless ENV["DATADOG_API_KEY"]
      raise AppKeyError unless ENV["DATADOG_APP_KEY"]

      adapter = Yabeda::Datadog::Adapter.new
      Yabeda.register_adapter(:datadog, adapter)
      adapter
    end

    def self.start_exporter(collect_interval: COLLECT_INTERVAL)
      Thread.new do
        Logging.instance.info "initilize collectors harvest"
        loop do
          Logging.instance.info "start collectors harvest"
          Yabeda.collectors.each(&:call)
          Logging.instance.info "end collectors harvest"
          sleep(collect_interval)
        end
      end
    end
  end
end
