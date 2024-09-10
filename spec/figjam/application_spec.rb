require "spec_helper"
require "tempfile"

describe Figjam::Application do
  before do
    allow_any_instance_of(described_class)
      .to receive(:default_path).and_return("/path/to/app/config/application.yml")
    allow_any_instance_of(described_class)
      .to receive(:default_environment).and_return("development")
  end

  describe "#path" do
    it "uses the default" do
      application = described_class.new

      expect(application.path).to eq("/path/to/app/config/application.yml")
    end

    it "is configurable via initialization" do
      application = described_class.new(path: "/app/env.yml")

      expect(application.path).to eq("/app/env.yml")
    end

    it "is configurable via setter" do
      application = described_class.new
      application.path = "/app/env.yml"

      expect(application.path).to eq("/app/env.yml")
    end

    it "casts to string" do
      application = described_class.new(path: Pathname.new("/app/env.yml"))

      expect(application.path).to eq("/app/env.yml")
      expect(application.environment).not_to be_a(Pathname)
    end

    it "follows a changing default" do
      application = described_class.new

      expect {
        allow(application).to receive(:default_path).and_return("/app/env.yml")
      }.to change {
        application.path
      }.from("/path/to/app/config/application.yml").to("/app/env.yml")
    end
  end

  describe "#environment" do
    it "uses the default" do
      application = described_class.new

      expect(application.environment).to eq("development")
    end

    it "is configurable via initialization" do
      application = described_class.new(environment: "test")

      expect(application.environment).to eq("test")
    end

    it "is configurable via setter" do
      application = described_class.new
      application.environment = "test"

      expect(application.environment).to eq("test")
    end

    it "casts to string" do
      application = described_class.new(environment: :test)

      expect(application.environment).to eq("test")
      expect(application.environment).not_to be_a(Symbol)
    end

    it "respects nil" do
      application = described_class.new(environment: nil)

      expect(application.environment).to be_nil
    end

    it "follows a changing default" do
      application = described_class.new

      expect {
        allow(application).to receive(:default_environment).and_return("test")
      }.to change {
        application.environment
      }.from("development").to("test")
    end
  end

  describe "#configuration" do
    # :reek:UtilityFunction
    def yaml_to_path(yaml)
      Tempfile.open("figjam") do |file|
        file.write(yaml)
        file.path
      end
    end

    it "loads values from YAML" do
      application = described_class.new(path: yaml_to_path(<<~YAML))
        foo: bar
      YAML

      expect(application.configuration).to eq("foo" => "bar")
    end

    it "merges environment-specific values" do
      application = described_class.new(path: yaml_to_path(<<~YAML), environment: "test")
        foo: bar
        test:
          foo: baz
      YAML

      expect(application.configuration).to eq("foo" => "baz")
    end

    it "drops unused environment-specific values" do
      application = described_class.new(path: yaml_to_path(<<~YAML), environment: "test")
        foo: bar
        test:
          foo: baz
        production:
          foo: bad
      YAML

      expect(application.configuration).to eq("foo" => "baz")
    end

    it "is empty when no YAML file is present" do
      application = described_class.new(path: "/path/to/nowhere")

      expect(application.configuration).to eq({})
    end

    it "is empty when the YAML file is blank" do
      application = described_class.new(path: yaml_to_path(""))

      expect(application.configuration).to eq({})
    end

    it "is empty when the YAML file contains only comments" do
      application = described_class.new(path: yaml_to_path(<<~YAML))
        # Comment
      YAML

      expect(application.configuration).to eq({})
    end

    it "processes ERB" do
      application = described_class.new(path: yaml_to_path(<<~YAML))
        foo: <%= "bar".upcase %>
      YAML

      expect(application.configuration).to eq("foo" => "BAR")
    end

    it "handles an empty environment block" do
      application = described_class.new(path: yaml_to_path("development:"))

      expect {
        application.configuration
      }.not_to raise_error
    end

    it "follows a changing default path" do
      path1 = yaml_to_path("foo: bar")
      path2 = yaml_to_path("foo: baz")

      application = described_class.new
      allow(application).to receive(:default_path) { path1 }

      expect {
        allow(application).to receive(:default_path) { path2 }
      }.to change {
        application.configuration
      }.from("foo" => "bar").to("foo" => "baz")
    end

    it "follows a changing default environment" do
      application = described_class.new(path: yaml_to_path(<<~YAML))
        foo: bar
        test:
          foo: baz
      YAML
      allow(application).to receive(:default_environment).and_return("development")

      expect {
        allow(application).to receive(:default_environment).and_return("test")
      }.to change {
        application.configuration
      }.from("foo" => "bar").to("foo" => "baz")
    end
  end

  describe "#load" do
    let!(:application) { described_class.new }

    before do
      allow(application).to receive(:configuration).and_return({ "foo" => "bar" })
    end

    it "merges values into ENV" do
      expect {
        application.load
      }.to change {
        ::ENV["foo"]
      }.from(nil).to("bar")
    end

    it "skips keys (and warns) that have already been set externally" do
      ::ENV["foo"] = "baz"

      expect(application)
        .to receive(:puts).with('INFO: Skipping key "foo". Already set in ENV.')

      expect {
        application.load
      }.not_to(
        change {
          ::ENV["foo"]
        }
      )
    end

    it "sets keys that have already been set internally" do
      application.load

      allow(application).to receive(:configuration).and_return({ "foo" => "baz" })

      expect {
        application.load
      }.to change {
        ::ENV["foo"]
      }.from("bar").to("baz")
    end

    shared_examples "correct warning with and without silence override" do
      [
        { FIGARO_SILENCE_STRING_WARNINGS: true },
        { "FIGARO_SILENCE_STRING_WARNINGS" => true },
        { FIGARO_SILENCE_STRING_WARNINGS: "true" },
        { "FIGARO_SILENCE_STRING_WARNINGS" => "true" },
        { FIGJAM_SILENCE_STRING_WARNINGS: true },
        { "FIGJAM_SILENCE_STRING_WARNINGS" => true },
        { FIGJAM_SILENCE_STRING_WARNINGS: "true" },
        { "FIGJAM_SILENCE_STRING_WARNINGS" => "true" },
      ].each do |override|
        it "does not warn with override #{override.inspect}" do
          allow(application).to receive(:configuration) { config.merge(override) }

          expect(application).not_to receive(:warn)

          application.load
        end
      end

      [
        [{}, 1],
        [{ "FIGARO_SILENCE_STRING_WARNINGS" => false }, 2],
        [{ FIGARO_SILENCE_STRING_WARNINGS: false }, 3],
        [{ "FIGARO_SILENCE_STRING_WARNINGS" => "false" }, 1],
        [{ FIGARO_SILENCE_STRING_WARNINGS: "false" }, 2],
        [{ "FIGJAM_SILENCE_STRING_WARNINGS" => false }, 2],
        [{ FIGJAM_SILENCE_STRING_WARNINGS: false }, 3],
        [{ "FIGJAM_SILENCE_STRING_WARNINGS" => "false" }, 1],
        [{ FIGJAM_SILENCE_STRING_WARNINGS: "false" }, 2],
      ].each do |override, expected_warning_count|
        it "warns #{expected_warning_count} times with override #{override.inspect}" do
          allow(application).to receive(:configuration) { config.merge(override) }

          expect(application).to receive(:warn).exactly(expected_warning_count).times

          application.load
        end
      end
    end

    context "when warning when a key isn't a string" do
      let(:config) { { SYMBOL_KEY: "string value" } }

      include_examples "correct warning with and without silence override"
    end

    context "when warning when a value isn't a string" do
      let(:config) { { "string key" => :SYMBOL_VALUE } }

      include_examples "correct warning with and without silence override"
    end

    it "allows nil values" do
      allow(application).to receive(:configuration).and_return({ "foo" => nil })

      expect {
        application.load
      }.not_to(
        change {
          ::ENV["foo"]
        }
      )
    end
  end
end
