# frozen_string_literal: true

require "bundler/setup"
require "yabeda/datadog"

# Put Datadog an API key in DATADOG_API_KEY env variable
# and appliction key in DATADOG_APP_KEY env variable.
# Refer to Datadog integrations dashboard for an API key

# To Use this script execute it directly with ruby command.
#
# Example:
#
#   DATADOG_API_KEY="your-datadog-api-key-here" ruby script.rb
#

Yabeda.configure do
  group :yabeda_datadog_gem_examples_script
  counter :run_count, comment: "The total number of times the script was executed", unit: "execution"
  gauge :run_time, comment: "Script execution time", unit: "second"
end

start_time = Time.now
Yabeda.yabeda_datadog_gem_examples_script_run_count.increment(device: "developent_computer")
finish_time = Time.now
Yabeda.yabeda_datadog_gem_examples_script_run_time.set({ device: "developent_computer" }, finish_time - start_time)
