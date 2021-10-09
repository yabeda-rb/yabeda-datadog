# frozen_string_literal: true

require "bundler/setup"
require "yabeda/datadog"

Thread.abort_on_exception = true
Yabeda::Datadog.config.log_level = Logger::DEBUG

yabeda_datadog = Yabeda::Datadog.start

# Make sure you start a datadog agent container with the command:
#
#   $ bin/dev
#
# To Use this script execute it directly with ruby command.
# You have to provide YABEDA_DATADOG_API_KEY and YABEDA_DATADOG_APP_KEY
# environment variables.
#
# Example:
#
#   YABEDA_DATADOG_API_KEY=<your API key> YABEDA_DATADOG_APP_KEY=<your app key> ruby examples/script.rb
#

Yabeda.configure do
  group :yabeda_datadog_gem_examples_script do
    counter :run_count, comment: "The total number of times the script was executed", unit: "time"
    gauge :run_time, comment: "Script execution time", unit: "second"
    histogram :rand_num, comment: "Random number", buckets: [0, 20, 40, 60, 80, 100]
  end
end

Yabeda.configure!

start_time = Time.now
Yabeda.yabeda_datadog_gem_examples_script.run_count.increment({ host: "dev_machine" }, by: 1)
Yabeda.yabeda_datadog_gem_examples_script.rand_num.measure({ host: "dev_machine", rand: true }, rand(100))
Yabeda.yabeda_datadog_gem_examples_script.rand_num.measure({ host: "dev_machine", rand: true }, rand(100))
Yabeda.yabeda_datadog_gem_examples_script.rand_num.measure({ host: "dev_machine", rand: true }, rand(100))
finish_time = Time.now
Yabeda.yabeda_datadog_gem_examples_script.run_time.set({ host: "dev_machine" }, finish_time - start_time)

puts "Type exit for exit the script" until gets.chomp =~ /^exit$/i
puts "Stoping Yabeda::Datadog, please wait ..."
yabeda_datadog.stop
