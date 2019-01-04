# frozen_string_literal: true

require "anyway"

module Yabeda
  module Datadog
    # = Describes all config variables
    class Config < Anyway::Config
      env_prefix :datadog
      config_name :datadog
      attr_config :api_key,
                  :app_key,
                  agent_host: "localhost",
                  agent_port: 8125,
                  batch_size: 10,
                  queue_size: 1000,
                  num_threads: 2,
                  sleep_interval: 3
    end
  end
end
