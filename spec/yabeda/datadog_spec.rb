# frozen_string_literal: true

RSpec.describe Yabeda::Datadog do
  it "has a version number" do
    expect(Yabeda::Datadog::VERSION).not_to be nil
  end

  describe "update metadata" do
    let(:dog_client) { instance_double("Dogapi::Client") }

    before do
      allow(dog_client).to receive(:update_metadata)
      allow(Dogapi::Client).to receive(:new).and_return(dog_client)
    end

    it "update counter metric metadata" do
      Yabeda.counter(:gate_opens, comment: "gate_opens description")
      expected_kwargs = { description: "gate_opens description", short_name: "gate_opens",
                          type: "counter", per_unit: nil, unit: nil, }
      expect(dog_client).to have_received(:update_metadata).with("gate_opens", expected_kwargs)
    end

    it "update gauge metric metadata" do
      Yabeda.gauge(:water_level, unit: "Ml", per: "???")
      expected_kwargs = { description: nil, short_name: "water_level",
                          type: "gauge", per_unit: "???", unit: "Ml", }
      expect(dog_client).to have_received(:update_metadata).with("water_level", expected_kwargs)
    end
  end

  describe "send metrics" do
    let(:dog_client) { instance_double("Dogapi::Client") }

    before do
      allow(dog_client).to receive(:emit_point)
      allow(dog_client).to receive(:update_metadata)
      allow(Dogapi::Client).to receive(:new).and_return(dog_client)

      Yabeda.configure do
        group :fake_dam

        counter :gate_opens
        gauge :water_level
      end
    end

    it "calls emit_point with an increment arguments" do
      Yabeda.fake_dam_gate_opens.increment(gate: :fake)
      expect(dog_client).to have_received(:emit_point).with("fake_dam.gate_opens", 1, type: "counter", gate: :fake)
    end

    it "calls emit_point with a gauge arguments" do
      Yabeda.fake_dam_water_level.set({}, 42)
      expect(dog_client).to have_received(:emit_point).with("fake_dam.water_level", 42, type: "gauge")
    end

    it "raise NotImplementedError when register histogram metric" do
      expect do
        Yabeda.histogram(:gate_throughput, unit: :cubic_meters, per: :gate_open, buckets: [1, 10, 100, 1_000, 10_000])
      end.to raise_error(NotImplementedError)
    end
  end
end
