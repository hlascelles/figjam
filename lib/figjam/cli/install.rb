require "thor/group"

module Figjam
  class CLI < Thor
    class Install < Thor::Group
      include Thor::Actions

      class_option "path",
                   aliases: ["-p"],
                   default: "config/application.yml",
                   desc: "Specify a configuration file path"

      def self.source_root
        File.expand_path("install", __dir__)
      end

      def create_configuration
        copy_file("application.yml", options[:path])
      end
    end
  end
end
