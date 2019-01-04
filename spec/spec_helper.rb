# frozen_string_literal: true

require "bundler/setup"
require "yabeda/datadog"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each, fake_thread: true) do
    allow(Thread).to receive(:new).and_yield
  end

  config.around(:each, fake_thread: true) do |example|
    prev_flag = Thread.abort_on_exception
    Thread.abort_on_exception = true
    example.run
    Thread.abort_on_exception = prev_flag
  end

  Yabeda::Datadog::Logging.instance.level = Logger::ERROR
end
