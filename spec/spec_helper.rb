require "bundler"
Bundler.setup

# This block of code helps to test the Railtie initialisation order. It cannot go directly in a spec
# as it is about how gems are required.
require "rails"
require "combustion"
Combustion.initialize!

require "figjam"
require "pry-byebug"

Bundler.require(:test)

Dir[File.expand_path("support/*.rb", __dir__)].each { |f| require f }
