# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Worker do
  let(:num_threads) { 2 }
  let(:queue_size) { 10 }
  let(:config) { instance_double("Yabeda::Datadog::Config", queue_size: queue_size, num_threads: num_threads) }

  describe "::start" do
    let(:worker) { instance_spy("Yabeda::Datadog::Worker") }

    before do
      allow(described_class).to receive(:new).and_return(worker)
    end

    it "create an instance of worker" do
      instance = described_class.start(config)
      expect(instance).to eq(worker)
    end

    it "spawns worker treads" do
      described_class.start(config)
      expect(worker).to have_received(:spawn_threads).with(num_threads)
    end
  end

  describe "#enqueue" do
    let(:queue) { Queue.new }
    let(:worker) { described_class.new(queue) }

    it "adds action and payload to queue" do
      worker.enqueue(:SEND, data: 1)
      expect(queue.pop).to eq([:SEND, { data: 1 }])
    end
  end

  describe "#spawn_threads" do
    let(:queue) { Queue.new }
    let(:worker) { described_class.new(queue) }

    before do
      allow(described_class::SEND).to receive(:call)
      allow(described_class::REGISTER).to receive(:call)
    end

    it "spawns given number of therads" do
      worker.spawn_threads(5)
      expect(worker.spawned_threads_count).to eq(5)
    end

    it "dispatches enqueued actions" do
      worker.enqueue(:SEND, a: 1)
      worker.enqueue(:SEND, b: 2)
      worker.enqueue(:REGISTER, name: :a)

      worker.spawn_threads(1)
      sleep(0.1)

      expect(described_class::SEND).to have_received(:call).with([{ a: 1 }, { b: 2 }])
      expect(described_class::REGISTER).to have_received(:call).with([{ name: :a }])
    end

    it "returns true" do
      expect(worker.spawn_threads(0)).to eq(true)
    end
  end

  describe "#stop" do
    let(:queue) { Queue.new }
    let(:worker) { described_class.new(queue) }
    let(:fake_thread) { instance_spy("Thread") }

    it "close worker's queue" do
      expect(queue).not_to be_closed
      worker.stop
      expect(queue).to be_closed
    end

    it "terminates all threads" do
      allow(Thread).to receive(:new).and_return(fake_thread)
      worker.spawn_threads(4)
      worker.stop
      expect(fake_thread).to have_received(:exit).exactly(4).times
    end

    it "empties treads list" do
      worker.spawn_threads(4)
      expect(worker.spawned_threads_count).to eq(4)
      worker.stop
      expect(worker.spawned_threads_count).to eq(0)
    end

    it "returns true" do
      expect(worker.stop).to eq(true)
    end
  end
end
