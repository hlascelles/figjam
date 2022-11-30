require "figjam/figaro_alias"

begin
  require "rails"
rescue LoadError
else
  require "figjam/rails/application"

  Figjam.adapter = Figjam::Rails::Application
  require "figjam/rails/railtie"
end

