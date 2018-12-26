# frozen_string_literal: true

require "bundler/setup"
require "yabeda/datadog"

Thread.abort_on_exception = true

# To Use this script execute it directly with ruby command.
# You have to provide DATADOG_API_KEY and DATADOG_APP_KEY
# environment variables.
#
# Example:
#
#   DATADOG_API_KEY=<your API key> DATADOG_APP_KEY=<your app key> ruby script.rb
#

Yabeda.configure do
  group :yabeda_datadog_gem_examples_script
  counter :run_count, comment: "The total number of times the script was executed", unit: "execution"
  gauge :run_time, comment: "Script execution time", unit: "second"
end

start_time = Time.now
Yabeda.yabeda_datadog_gem_examples_script_run_count.increment(host: "dev_machine")
finish_time = Time.now
Yabeda.yabeda_datadog_gem_examples_script_run_time.set({ host: "dev_machine" }, finish_time - start_time)
