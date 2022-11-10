require "thor"

module Figjam
  class CLI < Thor
    # figjam install

    desc "install", "Install Figjam"

    method_option "path",
      aliases: ["-p"],
      default: "config/application.yml",
      desc: "Specify a configuration file path"

    def install
      require "figjam/cli/install"
      Install.start
    end
  end
end
