# frozen_string_literal: true

require "spec_helper"

RSpec.describe Yabeda::Datadog::Unit do
  describe "::find" do
    it "returns unit if it available on Datadog" do
      expect(described_class.find("second")).to eq("second")
    end

    it "returns singular form of available unit" do
      expect(described_class.find("seconds")).to eq("second")
    end

    it "accepts symbols" do
      expect(described_class.find(:second)).to eq("second")
    end

    it "ignores case" do
      expect(described_class.find("SECond")).to eq("second")
    end

    it "returns singular form for non standard unit" do
      expect(described_class.find("fetches")).to eq("fetch")
      expect(described_class.find("queries")).to eq("query")
      expect(described_class.find("indices")).to eq("index")
    end

    it "returns nil if unit is not available" do
      expect(described_class.find("abra cadabra")).to be_nil
    end
  end
end
