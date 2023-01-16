# rubocop:disable Style/GlobalVars
RSpec.configure do |config|
  config.before(:suite) do
    $original_env_keys = ::ENV.keys
  end

  config.before do
    Figjam.adapter = nil
    Figjam.application = nil

    # Restore the original state of ENV for each test
    ::ENV.keep_if { |k, _| $original_env_keys.include?(k) }
  end
end
# rubocop:enable Style/GlobalVars
