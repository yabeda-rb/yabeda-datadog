# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Worker do
  let(:num_threads) { described_class::NUM_THREADS }

  describe "::start" do
    it "create an instance an spawns it's treads" do
      worker = instance_spy("Yabeda::Datadog::Worker")
      allow(described_class).to receive(:new).and_return(worker)

      instance = described_class.start

      expect(instance).to eq(worker)
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

    it "spawns given number of therads" do
      allow(Thread).to receive(:new)
      worker.spawn_threads(5)
      expect(Thread).to have_received(:new).exactly(5).times
    end

    it "dispatches enqueued actions" do
      allow(described_class::SEND).to receive(:call)
      allow(described_class::REGISTER).to receive(:call)
      worker.enqueue(:SEND, a: 1)
      worker.enqueue(:SEND, b: 2)
      worker.enqueue(:REGISTER, name: :a)

      worker.spawn_threads(3)
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

    it "empties worker's queue" do
      allow(described_class::SEND).to receive(:call)
      allow(described_class::REGISTER).to receive(:call)

      worker.enqueue(:SEND, {})
      worker.enqueue(:REGISTER, {})

      expect(queue).not_to be_empty
      worker.stop
      expect(queue).to be_empty
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
