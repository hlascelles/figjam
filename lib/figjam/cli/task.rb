require "figjam/application"

module Figjam
  class CLI < Thor
    class Task
      attr_reader :options

      def self.run(options = {})
        new(options).run
      end

      def initialize(options = {})
        @options = options
      end

      private def env
        ENV.to_hash.update(configuration)
      end

      private def configuration
        application.configuration
      end

      private def application
        @application ||= Figjam::Application.new(options)
      end

      if defined? Bundler
        def system(*)
          Bundler.with_clean_env { super }
        end
      end
    end
  end
end
