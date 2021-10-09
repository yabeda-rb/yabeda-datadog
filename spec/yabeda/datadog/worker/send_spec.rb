# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Worker::SEND do
  let(:send_method) { described_class }
  let(:metrics) { [] }

  let(:statsd_client) { instance_spy(Datadog::Statsd) }
  let(:statsd_client_options) do
    { single_thread: true }
  end

  before do
    allow(Datadog::Statsd).to receive(:new)
      .with(Yabeda::Datadog.config.agent_host, Yabeda::Datadog.config.agent_port, **statsd_client_options)
      .and_return(statsd_client)
  end

  it "instantiates statsd and closes it" do
    send_method.call(metrics)

    expect(Datadog::Statsd).to have_received(:new)
      .with(Yabeda::Datadog.config.agent_host, Yabeda::Datadog.config.agent_port, **statsd_client_options)
    expect(statsd_client).to have_received(:close)
  end
end
