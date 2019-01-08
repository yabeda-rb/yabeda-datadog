# frozen_string_literal: true

require "yabeda"
require "yabeda/datadog/adapter"
require "yabeda/datadog/version"
require "yabeda/datadog/exceptions"
require "yabeda/datadog/logging"
require "yabeda/datadog/response_handler"
require "yabeda/datadog/config"

module Yabeda
  # = Namespace for DataDog adapter
  module Datadog
    SECOND = 1
    COLLECT_INTERVAL = 60 * SECOND

    # Gem configuration object
    def self.config
      @config ||= Config.new
    end

    # Check the gem configuration has valid state
    def self.ensure_configured
      raise ApiKeyError unless config.api_key
      raise AppKeyError unless config.app_key
    end

    # Prepare the adapter to work
    def self.start
      ensure_configured

      worker = Yabeda::Datadog::Worker.start(config)
      adapter = Yabeda::Datadog::Adapter.new(worker: worker)
      Yabeda.register_adapter(:datadog, adapter)
      adapter
    end

    # Start collection metrics from Yabeda collectors
    def self.start_exporter(collect_interval: COLLECT_INTERVAL)
      Thread.new do
        Logging.instance.debug("initilize collectors harvest")
        loop do
          Logging.instance.debug("start collectors harvest")
          Yabeda.collectors.each(&:call)
          Logging.instance.debug("end collectors harvest")
          sleep(collect_interval)
        end
      end
    end
  end
end
