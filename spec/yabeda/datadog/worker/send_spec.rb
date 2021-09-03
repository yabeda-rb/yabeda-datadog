# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Worker::SEND do
  let(:send_method) { described_class }
  let(:metrics) { [] }

  let(:statsd_client) { instance_spy(Datadog::Statsd) }
  let(:statsd_client_options) do
    # This tests is run with both ~> 4.0 and latest dogstatsd-ruby.
    if Gem::Version.new(Datadog::Statsd::VERSION) >= Gem::Version.new('5.2.0')
      { single_thread: true }
    else
      {}
    end
  end

  it "instantiates statsd and closes it" do
    expect(Datadog::Statsd).to receive(:new)
      .with(Yabeda::Datadog.config.agent_host, Yabeda::Datadog.config.agent_port, **statsd_client_options)
      .and_return(statsd_client)
    expect(statsd_client).to receive(:close)

    send_method.call(metrics)
  end
end
