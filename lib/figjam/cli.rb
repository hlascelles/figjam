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

    # figjam heroku:set

    desc "heroku:set", "Send Figjam configuration to Heroku"

    method_option "app",
      aliases: ["-a"],
      desc: "Specify a Heroku app"
    method_option "environment",
      aliases: ["-e"],
      desc: "Specify an application environment"
    method_option "path",
      aliases: ["-p"],
      default: "config/application.yml",
      desc: "Specify a configuration file path"
    method_option "remote",
      aliases: ["-r"],
      desc: "Specify a Heroku git remote"

    define_method "heroku:set" do
      require "figjam/cli/heroku_set"
      HerokuSet.run(options)
    end
  end
end
