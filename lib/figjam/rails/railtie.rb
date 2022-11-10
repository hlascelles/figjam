module Figjam
  module Rails
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        Figjam.load
      end
    end
  end
end
