require "spec_helper"

describe Figjam do
  describe ".env" do
    it "falls through to Figjam::ENV" do
      expect(described_class.env).to eq(described_class::ENV)
    end
  end

  describe ".adapter" do
    let(:adapter) { class_double(described_class::Application) }

    it "defaults to the generic application adapter" do
      expect(described_class.adapter).to eq(described_class::Application)
    end

    it "is configurable" do
      expect {
        described_class.adapter = adapter
      }.to change(described_class, :adapter).from(described_class::Application).to(adapter)
    end
  end

  describe ".application" do
    let(:adapter) { class_double(described_class::Application) }
    let(:application) { instance_double(described_class::Application) }
    let(:custom_application) { instance_double(described_class::Application) }

    before do
      allow(described_class).to receive(:adapter) { adapter }
      allow(adapter).to receive(:new).with(no_args) { application }
    end

    it "defaults to a new adapter application" do
      expect(described_class.application).to eq(application)
    end

    it "is configurable" do
      expect {
        described_class.application = custom_application
      }.to change(described_class, :application).from(application).to(custom_application)
    end
  end

  describe ".load" do
    let(:application) { instance_double(described_class::Application) }

    before do
      allow(described_class).to receive(:application) { application }
    end

    it "loads the application configuration" do
      expect(application).to receive(:load).once.with(no_args)

      described_class.load
    end
  end

  describe "#configuration" do
    it "includes configuration using YAML aliases" do
      expect(ENV.fetch("WHEEL_COUNT", nil)).to eq("4")
    end
  end

  describe "railtie configuration" do
    it "loads railtie after the adapter is set to Figaro::Rails::Application" do
      expect(ENV.fetch("ENGINE_VALUE", nil)).to eq("diesel")
    end
  end

  describe ".require_keys" do
    before do
      ::ENV["foo"] = "bar"
      ::ENV["hello"] = "world"
    end

    context "when no keys are missing" do
      it "does nothing" do
        expect {
          described_class.require_keys("foo", "hello")
        }.not_to raise_error
      end

      it "accepts an array" do
        expect {
          described_class.require_keys(%w[foo hello])
        }.not_to raise_error
      end
    end

    context "when keys are missing" do
      it "raises an error for the missing keys" do
        expect {
          described_class.require_keys("foo", "goodbye", "baz")
        }.to raise_error(described_class::MissingKeys) { |error|
          expect(error.message).not_to include("foo")
          expect(error.message).to include("goodbye")
          expect(error.message).to include("baz")
        }
      end

      it "accepts an array" do
        expect {
          described_class.require_keys(%w[foo goodbye baz])
        }.to raise_error(described_class::MissingKeys)
      end
    end
  end
end
