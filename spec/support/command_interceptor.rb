require "fileutils"
require "ostruct"
require "yaml"

module CommandInterceptor
  class Command < Struct
  end

  BIN_PATH = File.expand_path("bin", __dir__)
  LOG_PATH = File.expand_path("../../tmp/commands.yml", __dir__)

  def self.setup
    ENV["PATH"] = "#{BIN_PATH}:#{ENV.fetch('PATH', nil)}"
  end

  def self.intercept(name)
    FileUtils.mkdir_p(File.dirname(LOG_PATH))
    FileUtils.touch(LOG_PATH)

    command = { "env" => ENV.to_hash, "name" => name, "args" => ARGV }
    commands = self.commands << command

    File.write(LOG_PATH, YAML.dump(commands))
  end

  def self.commands
    ((File.exist?(LOG_PATH) && YAML.load_file(LOG_PATH)) || []).map { |c| Command.new(c) }
  end

  def self.reset
    FileUtils.rm_f(LOG_PATH)
  end
end
