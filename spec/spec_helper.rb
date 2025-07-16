require "bundler"
Bundler.setup

require "combustion"
Combustion.initialize!

require "figjam"
require "pry-byebug"

Bundler.require(:test)

Dir[File.expand_path("support/*.rb", __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
end
