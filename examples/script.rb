# frozen_string_literal: true

require "bundler/setup"
require "yabeda/datadog"

Thread.abort_on_exception = true

yabeda_datadog = Yabeda::Datadog.start

# To Use this script execute it directly with ruby command.
# You have to provide DATADOG_API_KEY and DATADOG_APP_KEY
# environment variables.
#
# Example:
#
#   DATADOG_API_KEY=<your API key> DATADOG_APP_KEY=<your app key> ruby examples/script.rb
#

Yabeda.configure do
  group :yabeda_datadog_gem_examples_script
  counter :run_count, comment: "The total number of times the script was executed", unit: "time"
  gauge :run_time, comment: "Script execution time", unit: "second"
  histogram :rand_num, comment: "Random number", buckets: [0, 20, 40, 60, 80, 100]
end

start_time = Time.now
Yabeda.yabeda_datadog_gem_examples_script_run_count.increment(host: "dev_machine")
Yabeda.yabeda_datadog_gem_examples_script_rand_num.measure({ host: "dev_machine", rand: true }, rand(100))
Yabeda.yabeda_datadog_gem_examples_script_rand_num.measure({ host: "dev_machine", rand: true }, rand(100))
Yabeda.yabeda_datadog_gem_examples_script_rand_num.measure({ host: "dev_machine", rand: true }, rand(100))
finish_time = Time.now
Yabeda.yabeda_datadog_gem_examples_script_run_time.set({ host: "dev_machine" }, finish_time - start_time)

sleep(10)
yabeda_datadog.stop
