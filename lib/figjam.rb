if Gem.loaded_specs.key?("figaro")
  raise "The gem figjam is a replacement for figaro. Remove figaro from your Gemfile."
end

require "figjam/error"
require "figjam/env"
require "figjam/application"

module Figjam
  extend self # rubocop:disable Style/ModuleFunction

  attr_writer :adapter, :application

  def env
    Figjam::ENV
  end

  def adapter
    @adapter ||= Figjam::Application
  end

  def application
    @application ||= adapter.new
  end

  def load
    application.load
  end

  def require_keys(*keys)
    missing_keys = keys.flatten - ::ENV.keys
    raise MissingKeys, missing_keys if missing_keys.any?
  end
end

require "figjam/rails"
