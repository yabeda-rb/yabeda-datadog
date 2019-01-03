# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Adapter do
  let(:worker) { instance_spy("Yabeda::Datadog::Worker") }
  let(:adapter) { described_class.new(worker: worker) }
  let(:metric) { instance_double("Yabeda::Datadog::Metric") }

  describe "#register_counter!" do
    it "enqueued update a counter metric action" do
      yabeda_metric = instance_double("Yabeda::Counter")
      allow(Yabeda::Datadog::Metric).to receive(:new).with(yabeda_metric, "count").and_return(metric)
      adapter.register_counter!(yabeda_metric)
      expect(worker).to have_received(:enqueue).with(:REGISTER, metric: metric)
    end
  end

  describe "#register_gauge!" do
    it "enqueued update a gauge metric action" do
      yabeda_metric = instance_double("Yabeda::Gauge")
      allow(Yabeda::Datadog::Metric).to receive(:new).with(yabeda_metric, "gauge").and_return(metric)
      adapter.register_gauge!(yabeda_metric)
      expect(worker).to have_received(:enqueue).with(:REGISTER, metric: metric)
    end
  end

  describe "#register_histogram!" do
    it "enqueued update a histogram metric action" do
      yabeda_metric = instance_double("Yabeda::Histogram")
      allow(Yabeda::Datadog::Metric).to receive(:new).with(yabeda_metric, "gauge", instance_of(Hash)).and_return(metric)
      allow(Yabeda::Datadog::Metric).to receive(:new).with(yabeda_metric, "rate", instance_of(Hash)).and_return(metric)
      adapter.register_histogram!(yabeda_metric)
      expect(worker).to have_received(:enqueue).with(:REGISTER, metric: metric).exactly(6).times
    end
  end

  describe "#perform_histogram_measure!" do
    let(:yabeda_empty_tags) { {} }

    it "enqueued send a counter metric action" do
      yabeda_metric = instance_double("Yabeda::Counter")
      allow(Yabeda::Datadog::Metric).to receive(:new).with(yabeda_metric, "count").and_return(metric)
      adapter.perform_counter_increment!(yabeda_metric, yabeda_empty_tags, 1)
      expect(worker).to have_received(:enqueue).with(:SEND, metric: metric, value: 1, tags: [])
    end

    it "enqueued send a gauge metric action" do
      yabeda_metric = instance_double("Yabeda::Gauge")
      allow(Yabeda::Datadog::Metric).to receive(:new).with(yabeda_metric, "gauge").and_return(metric)
      adapter.perform_gauge_set!(yabeda_metric, yabeda_empty_tags, 227)
      expect(worker).to have_received(:enqueue).with(:SEND, metric: metric, value: 227, tags: [])
    end

    it "enqueued send a histogram metric action" do
      yabeda_metric = instance_double("Yabeda::Histogram")
      allow(Yabeda::Datadog::Metric).to receive(:new).with(yabeda_metric, "histogram").and_return(metric)
      adapter.perform_histogram_measure!(yabeda_metric, yabeda_empty_tags, 13)
      expect(worker).to have_received(:enqueue).with(:SEND, metric: metric, value: 13, tags: [])
    end
  end
end
