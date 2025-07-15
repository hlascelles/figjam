require "erb"
require "yaml"
require "figjam/figaro_alias"

module Figjam
  class InvalidKeyNameError < StandardError; end

  # :reek:TooManyMethods
  class Application
    FIGARO_ENV_PREFIX = "_FIGARO_".freeze
    SILENCE_STRING_WARNINGS_KEYS = %i[
      FIGARO_SILENCE_STRING_WARNINGS
      FIGJAM_SILENCE_STRING_WARNINGS
    ].freeze

    include Enumerable

    def initialize(options = {})
      @options = options.transform_keys(&:to_sym)
    end

    def path
      @options.fetch(:path) { default_path }.to_s
    end

    def path=(path)
      @options[:path] = path
    end

    def environment
      environment = @options.fetch(:environment) { default_environment }
      environment&.to_s
    end

    def environment=(environment)
      @options[:environment] = environment
    end

    def configuration
      global_configuration.merge(environment_configuration)
    end

    def load
      each do |key, value|
        if !valid_key_name?(key)
          invalid_key_name(key)
        elsif skip?(key)
          key_skipped(key)
        else
          set(key, value)
        end
      end
    end

    def each(&)
      configuration.each(&)
    end

    private def default_path
      raise NotImplementedError
    end

    private def default_environment
      nil
    end

    private def raw_configuration
      (@parsed ||= Hash.new { |hash, path| hash[path] = parse(path) })[path]
    end

    private def parse(path)
      raise ArgumentError, "Figjam config path #{path} not found" unless File.exist?(path)

      load_yaml(ERB.new(File.read(path)).result) # nosemgrep
    end

    # rubocop:disable Security/YAMLLoad
    private def load_yaml(source)
      # https://bugs.ruby-lang.org/issues/17866
      # https://github.com/rails/rails/commit/179d0a1f474ada02e0030ac3bd062fc653765dbe
      YAML.load(source, aliases: true) || {}
    rescue ArgumentError
      YAML.load(source) || {}
    end
    # rubocop:enable Security/YAMLLoad

    private def global_configuration
      raw_configuration.reject { |_, value| value.is_a?(Hash) }
    end

    private def environment_configuration
      raw_configuration[environment] || {}
    end

    private def set(key, value)
      unless non_string_warnings_silenced?
        non_string_configuration(key) unless key.is_a?(String)
        non_string_configuration(value) unless value.is_a?(String) || value.nil?
      end

      ::ENV[key.to_s] = value&.to_s
      ::ENV[FIGARO_ENV_PREFIX + key.to_s] = value&.to_s
    end

    private def skip?(key)
      ::ENV.key?(key.to_s) && !::ENV.key?(FIGARO_ENV_PREFIX + key.to_s)
    end

    private def non_string_warnings_silenced?
      SILENCE_STRING_WARNINGS_KEYS.any? { |key|
        # Allow the silence configuration itself to use non-string keys/values.
        configuration.values_at(key.to_s, key).any? { |cv| cv.to_s == "true" }
      }
    end

    private def non_string_configuration(value)
      warn "WARNING: Use strings for Figjam configuration. #{value.inspect} was converted to #{value.to_s.inspect}." # rubocop:disable Layout/LineLength
    end

    private def key_skipped(key)
      puts "INFO: Skipping key #{key.inspect}. Already set in ENV."
    end

    private def valid_key_name?(key)
      key.to_s == key.to_s.upcase
    end

    private def invalid_key_name(key)
      raise InvalidKeyNameError, "Environment variable names must be uppercase: #{key.inspect}"
    end
  end
end
