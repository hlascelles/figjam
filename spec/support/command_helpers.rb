RSpec.configure do |config|
  config.before(:suite) do
    CommandInterceptor.setup
  end

  config.before do
    CommandInterceptor.reset
  end
end
