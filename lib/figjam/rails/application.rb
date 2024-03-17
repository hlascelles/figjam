module Figjam
  module Rails
    class Application < Figjam::Application
      private def default_path
        rails_not_initialized unless ::Rails.root

        ::Rails.root.join("config", "application.yml")
      end

      private def default_environment
        ::Rails.env
      end

      private def rails_not_initialized
        raise RailsNotInitialized
      end
    end
  end
end
