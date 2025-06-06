require "spec_helper"

describe Figjam::Rails do
  before do
    run_command_and_stop(<<-CMD)
      rails _8.0.2_ new example \
        --skip-gemfile \
        --skip-activerecord \
        --skip-git \
        --skip-keeps \
        --skip-sprockets \
        --skip-spring \
        --skip-listen \
        --skip-javascript \
        --skip-turbolinks \
        --skip-test \
        --skip-bootsnap \
        --no-rc \
        --skip-bundle \
        --skip-webpack-install
    CMD

    # Rails 7 doesn't expect the config.assets line, so comment it out or delete references to it
    development_file = "tmp/aruba/example/config/environments/development.rb"
    development_config = File.read(development_file)
    File.write(development_file, development_config.gsub(" config.assets", " # config.assets"))
    assets_initializer = "tmp/aruba/example/config/initializers/assets.rb"
    FileUtils.rm_f(assets_initializer)

    # Cater for some versions of psych not supporting yaml anchors unless the `aliases: true`
    # option is set. This is an internal call in Rails so we cannot fix it there. We should review
    # this when on later versions of ruby and Rails.
    database_file = "tmp/aruba/example/config/database.yml"
    File.write(database_file, <<-STR)
      development:
        adapter: sqlite3
        pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
        timeout: 5000
        database: db/test.sqlite3
    STR

    cd("example")
  end

  describe "initialization" do
    before do
      write_file("config/application.yml", "FOO: bar")
    end

    it "loads application.yml" do
      run_command_and_stop("rails runner 'puts Figjam.env.FOO'")

      expect(all_stdout).to include("bar")
    end

    it "happens before database initialization" do
      write_file("config/database.yml", <<~STR)
        development:
          adapter: sqlite3
          database: db/<%= ENV["FOO"] %>.sqlite3

        test:
          adapter: sqlite3
          database: db/<%= ENV["FOO"] %>.sqlite3
      STR

      run_command_and_stop("rake db:migrate")

      expect("db/bar.sqlite3").to be_an_existing_file
    end

    it "happens before application configuration" do
      insert_into_file_after("config/application.rb", /< Rails::Application$/, <<-STR)
    config.FOO = ENV["FOO"]
      STR

      run_command_and_stop("rails runner 'puts Rails.application.config.FOO'")

      expect(all_stdout).to include("bar")
    end
  end
end
