require_relative "../application"

module Figjam
  module Rails
    module Engine
      class << self
        def configure(engine_context, environment = ::Rails.env)
          engine_context.config.before_configuration do
            Figjam::Application.new(
              environment: environment,
              path: "#{engine_context.root}/config/application.yml"
            ).load
          end
        end
      end
    end
  end
end
