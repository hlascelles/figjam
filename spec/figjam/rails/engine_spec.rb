require "spec_helper"
require "figjam/rails/engine"

describe Figjam::Rails::Engine do
  describe ".configure" do
    let(:test_engine_class) do
      Class.new(::Rails::Engine) do
        def self.root
          Pathname.new(File.expand_path("../../..", __dir__))
        end
      end
    end

    it "sets up before_configuration callback" do
      expect(test_engine_class.config).to receive(:before_configuration).and_call_original
      described_class.configure(test_engine_class, "test")
    end
  end
end
