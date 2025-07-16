require "figjam/figaro_alias"

begin
  require "rails"
rescue LoadError
  # Cater for no Rails
else
  require "figjam/rails/application"
  require "figjam/rails/engine"

  Figjam.adapter = Figjam::Rails::Application
  require "figjam/rails/railtie"
end
