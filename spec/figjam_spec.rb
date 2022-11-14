require "spec_helper"

describe Figjam do
  describe ".env" do
    it "falls through to Figjam::ENV" do
      expect(Figjam.env).to eq(Figjam::ENV)
    end
  end

  describe ".adapter" do
    let(:adapter) { double(:adapter) }

    it "defaults to the generic application adapter" do
      expect(Figjam.adapter).to eq(Figjam::Application)
    end

    it "is configurable" do
      expect {
        Figjam.adapter = adapter
      }.to change {
        Figjam.adapter
      }.from(Figjam::Application).to(adapter)
    end
  end

  describe ".application" do
    let(:adapter) { double(:adapter) }
    let(:application) { double(:application) }
    let(:custom_application) { double(:custom_application) }

    before do
      allow(Figjam).to receive(:adapter) { adapter }
      allow(adapter).to receive(:new).with(no_args) { application }
    end

    it "defaults to a new adapter application" do
      expect(Figjam.application).to eq(application)
    end

    it "is configurable" do
      expect {
        Figjam.application = custom_application
      }.to change {
        Figjam.application
      }.from(application).to(custom_application)
    end
  end

  describe ".load" do
    let(:application) { double(:application) }

    before do
      allow(Figjam).to receive(:application) { application }
    end

    it "loads the application configuration" do
      expect(application).to receive(:load).once.with(no_args)

      Figjam.load
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
          Figjam.require_keys("foo", "hello")
        }.not_to raise_error
      end

      it "accepts an array" do
        expect {
          Figjam.require_keys(["foo", "hello"])
        }.not_to raise_error
      end
    end

    context "when keys are missing" do
      it "raises an error for the missing keys" do
        expect {
          Figjam.require_keys("foo", "goodbye", "baz")
        }.to raise_error(Figjam::MissingKeys) { |error|
          expect(error.message).not_to include("foo")
          expect(error.message).to include("goodbye")
          expect(error.message).to include("baz")
        }
      end

      it "accepts an array" do
        expect {
          Figjam.require_keys(["foo", "goodbye", "baz"])
        }.to raise_error(Figjam::MissingKeys)
      end
    end
  end
end
