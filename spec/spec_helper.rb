require "bundler"
Bundler.setup

require "figjam"

Bundler.require(:test)

Dir[File.expand_path("../support/*.rb", __FILE__)].each { |f| require f }
