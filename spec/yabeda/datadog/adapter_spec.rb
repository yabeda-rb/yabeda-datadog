# frozen_string_literal: true

RSpec.describe Yabeda::Datadog::Adapter do
  describe "dogapi integration" do
    it "expects Dogapi::Client to respond to new" do
      expect(Dogapi::Client).to respond_to(:new)
    end
  end

  describe "dogstatsd integration" do
    it "expects Datadog::Statsd to respond to new" do
      expect(Datadog::Statsd).to respond_to(:new)
    end
  end

  describe "register metrics" do
    let(:dog_client) { instance_double("Dogapi::Client") }

    before do
      allow(dog_client).to receive(:update_metadata)
      allow(::Dogapi::Client).to receive(:new).and_return(dog_client)
    end

    it "calls dogapi update_metadata with counter metric", fake_thread: true do
      Yabeda.counter(:script_runs, comment: "How many times the script has been run", unit: "time")
      expected_kwargs = { description: "How many times the script has been run", short_name: "script_runs",
                          type: "counter", per_unit: nil, unit: "time", }
      expect(dog_client).to have_received(:update_metadata).with("script_runs", expected_kwargs)
    end

    it "calls dogapi update_metadata with gauge metric", fake_thread: true do
      Yabeda.gauge(:processes, unit: "item")
      expected_kwargs = { description: nil, short_name: "processes",
                          type: "gauge", per_unit: nil, unit: "item", }
      expect(dog_client).to have_received(:update_metadata).with("processes", expected_kwargs)
    end

    it "calls dogapi update_metadata with all histogram metrics", fake_thread: true do
      Yabeda.histogram(:request_duration, unit: "millisecond", per: "request", buckets: [1, 10, 100, 1_000, 10_000])
      expect(dog_client).to have_received(:update_metadata).with("request_duration.avg",
                                                                 short_name: "request_duration.avg",
                                                                 description: nil,
                                                                 unit: "millisecond",
                                                                 per_unit: "request",
                                                                 type: "gauge",)
      expect(dog_client).to have_received(:update_metadata).with("request_duration.count",
                                                                 short_name: "request_duration.count",
                                                                 description: nil,
                                                                 unit: nil,
                                                                 per_unit: nil,
                                                                 type: "rate",)
      expect(dog_client).to have_received(:update_metadata).with("request_duration.median",
                                                                 short_name: "request_duration.median",
                                                                 description: nil,
                                                                 unit: "millisecond",
                                                                 per_unit: "request",
                                                                 type: "gauge",)
      expect(dog_client).to have_received(:update_metadata).with("request_duration.95percentile",
                                                                 short_name: "request_duration.95percentile",
                                                                 description: nil,
                                                                 unit: nil,
                                                                 per_unit: nil,
                                                                 type: "gauge",)
      expect(dog_client).to have_received(:update_metadata).with("request_duration.max",
                                                                 short_name: "request_duration.max",
                                                                 description: nil,
                                                                 unit: "millisecond",
                                                                 per_unit: "request",
                                                                 type: "gauge",)
      expect(dog_client).to have_received(:update_metadata).with("request_duration.min",
                                                                 short_name: "request_duration.min",
                                                                 description: nil,
                                                                 unit: "millisecond",
                                                                 per_unit: "request",
                                                                 type: "gauge",)
    end
  end

  describe "custom metrics" do
    let(:dog_client) { instance_double("dogapi::client") }
    let(:dogstatsd) { instance_double("datadog::statsd") }

    before do
      allow(dog_client).to receive(:update_metadata)
      allow(Dogapi::Client).to receive(:new).and_return(dog_client)

      allow(Datadog::Statsd).to receive(:new).and_return(dogstatsd)
      allow(dogstatsd).to receive(:count)
      allow(dogstatsd).to receive(:gauge)
      allow(dogstatsd).to receive(:histogram)

      Yabeda.configure do
        group :sidekiq

        counter :job_executed_total
        gauge :active_workers_count
        histogram :job_runtime, unit: :seconds, per: :item, buckets: [1, 10, 100, 1_000, 10_000]
      end
    end

    it "sends counter metric to dogstats-d", fake_thread: true do
      Yabeda.sidekiq_job_executed_total.increment(host: :a, success: true)
      expect(dogstatsd).to have_received(:count).with("sidekiq.job_executed_total", 1, tags: ["host:a", "success:true"])
    end

    it "sends gauge metric to dogstats-d", fake_thread: true do
      Yabeda.sidekiq_active_workers_count.set({}, 42)
      expect(dogstatsd).to have_received(:gauge).with("sidekiq.active_workers_count", 42, tags: [])
    end

    it "sends histogram metric to dogstats-d", fake_thread: true do
      Yabeda.sidekiq_job_runtime.measure({ any: :whatever }, 4321)
      expect(dogstatsd).to have_received(:histogram).with("sidekiq.job_runtime", 4321, tags: ["any:whatever"])
    end
  end
end
