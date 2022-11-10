require "figjam/figaro_alias"

begin
  require "rails"
rescue LoadError
else
  require "figjam/rails/application"
  require "figjam/rails/railtie"

  Figjam.adapter = Figjam::Rails::Application
end

