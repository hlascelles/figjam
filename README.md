<img align="right" width="150" src="jamjar.png">

figjam
================

[![Gem Version](https://img.shields.io/gem/v/figjam?color=green)](https://rubygems.org/gems/figjam)
[![specs workflow](https://github.com/hlascelles/figjam/actions/workflows/specs.yml/badge.svg)](https://github.com/hlascelles/figjam/actions)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Figjam makes it easy to configure ruby and Rails apps `ENV` values by just using a single YAML file.

PRs to applications often need to come with default configuration values, but hardcoding these into
software makes them impossible to change at runtime. However supplying them separately to an
orchestration framework introduces deploy coordination that can be tricky to get right.

Figjam encourages you to commit default ENV values to a yaml file in your PRs. These are then
loaded at runtime, but, crucially, can be overridden at any time by supplying a real ENV. This
brings the ease of PR creation with the flexibility of runtime ENV changes.

An example configuration file might look like this:

```yaml
GOOGLE_TAG_MANAGER_ID: GTM-12345
PAYMENT_ENDPOINT: https://payments.localhost

prelive:
  GOOGLE_TAG_MANAGER_ID: GTM-54321
  PAYMENT_ENDPOINT: https://payments-prelive.example.com

production:
  GOOGLE_TAG_MANAGER_ID: GTM-34343
  PAYMENT_ENDPOINT: https://payments.example.com
```

### Installation

Figjam can be used with or without Rails. If using Bundler, add Figjam to your Gemfile and `bundle install`:

```ruby
gem "figjam"
```

### Usage with Rails 

Figjam will load itself automatically if you are using Rails. It will look for a
`config/application.yml` file for ENV configuration.

You can create a default configuration file by running:

```bash
$ bundle exec figjam install
```

This creates a commented `config/application.yml` file which you can add default ENV to.
Add your own configuration to this file for all environments, and any specific environment
overrides.

### Usage in Rails engines

Figjam is perfect for Rails engines. They can have their own configuration file, and
they can be loaded independently or in addition of the main application. To do this,
you can create a `config/application.yml` file in your engine, and add this initializer:

```ruby
Figjam::Application.new(
  environment: ::Rails.env,
  path: File.expand_path("../application.yml", __dir__)
).load
```

### Usage without Rails

If you are not using Rails, you can load Figjam in your gem. Note, you can
do this as many times as you like. If you have multiple internal gems, they can
all use `figjam` to load their own configuration independently.

```ruby
Figjam::Application.new(
  environment: "some_environment_key",
  path: "#{__dir__}/application.yml"
).load
```

### How the loaded configuration is used 

The configuration file is loaded by `figjam` into `ENV` at runtime. If any of the keys are already
set in the process ENV, then the ENV value will take precedence.

In terms of the file itself, the non-indented values at the top are the default values and will be
used unless RAILS_ENV matches any of the subsequent keys (like `test`, `prelive`, `production`).

```yaml
# config/application.yml

GOOGLE_TAG_MANAGER_ID: GTM-12345

test:
  # Use ~ for "nil"
  GOOGLE_TAG_MANAGER_ID: ~
  
prelive:
  GOOGLE_TAG_MANAGER_ID: GTM-45678

production:
  GOOGLE_TAG_MANAGER_ID: GTM-98765
```

You can then use those values in your app in an initializer, or in any other ruby code.

eg:
```
# app/views/layouts/application.html.erb

<script>
var gtm_id = <%= ENV.fetch("GOOGLE_TAG_MANAGER_ID") %> 
</script>
```

Note, secrets are not to be provided by figjam, so do not add them to your `application.yml`.

Deeply nested configuration structures are not possible.

## Silencing type conversion warnings

Remember that `ENV` in ruby is a simple key/value store. All values will always be strings.
This means that the following code will produce string values:

```yaml
SOME_NUMBER: 3
SOME_BOOLEAN: true
```

```ruby
# WARNING: Use strings for Figjam configuration. 3 was converted to "3"
# WARNING: Use strings for Figjam configuration. true was converted to "true"

ENV["SOME_NUMBER"] == 3 # => false
ENV["SOME_NUMBER"] == "3" # => true
ENV["SOME_BOOLEAN"] == true # => false
ENV["SOME_BOOLEAN"] == "true" # => true
```

Because this is a possible cause of sleeper bugs, Figjam emits a warning when it does this
conversion to a string. If you are confident in your abilities, you can silence it by adding this
to the top of your `application.yml`:

```yaml
FIGJAM_SILENCE_STRING_WARNINGS: true
```

### Using `Figjam.env`

`Figjam.env` is a convenience that acts as a proxy to `ENV`.

In testing, it is sometimes more convenient to stub and unstub `Figjam.env` than
to set and reset `ENV`. Whether your application uses `ENV` or `Figjam.env` is
entirely a matter of personal preference.

```yaml
# config/application.yml

GOOGLE_TAG_MANAGER_ID: "GTM-456789"
```

```ruby
ENV["GOOGLE_TAG_MANAGER_ID"] # => "GTM-456789"
ENV.key?("GOOGLE_TAG_MANAGER_ID") # => true
ENV["SOMETHING_ELSE"] # => nil
ENV.key?("SOMETHING_ELSE") # => false

Figjam.env.google_tag_manager_id # => "GTM-456789"
Figjam.env.google_tag_manager_id? # => true
Figjam.env.something_else # => nil
Figjam.env.something_else? # => false
```

If you wish to use `ENV` in specs and want to temporarily change what it returns, you should
definitely look at using the excellent [climate_control](https://github.com/thoughtbot/climate_control)
gem.

### Required Keys

If a particular configuration value is required but not set, it's appropriate to
raise an error. With Figjam, you can either raise these errors proactively or
lazily.

To proactively require configuration keys:

```ruby
# config/initializers/figjam.rb

Figjam.require_keys("GOOGLE_TAG_MANAGER_ID")
```

If any of the configuration keys above are not set, your application will raise
an error during initialization. This method is preferred because it prevents
runtime errors in a production application due to improper configuration.

To require configuration keys lazily, reference the variables via "bang" methods
on `Figjam.env`:

```ruby
gtm_id = Figjam.env.google_tag_manager_id!
```

## Is Figjam like [dotenv](https://github.com/bkeepers/dotenv)?

Figjam and dotenv are similar:

### Similarities

* Both libraries are useful for Ruby application configuration.
* Both are inspired by Twelve-Factor App's concept of proper [configuration](http://12factor.net/config).
* Both store configuration values in `ENV`.
* Both can be used in and out of Rails.

### Differences

* Configuration File
  * Figjam only needs a single file.
  * Dotenv must use separate files for each environment.
* Configuration File Format
  * Figjam expects YAML containing key/value pairs.
  * Dotenv convention is a collection of `KEY=VALUE` pairs.

If you prefer your default configuration in one place, where you can scan one file to see
differences between environments, then you may prefer `figjam` over `dotenv`.

## Is application.yml like [secrets.yml](https://github.com/rails/rails/blob/v4.1.0/railties/lib/rails/generators/rails/app/templates/config/secrets.yml)?

No. Do not put secrets in `figjam` `application.yml` files! That file supposed to be committed
to source control, and should never contain secrets.

### Spring Configuration

If you're using Spring add `config/application.yml` to the watch list:

```rb
# config/spring.rb

%w(
  ...
  config/application.yml
).each { |path| Spring.watch(path) }
```

## Figjam origins

Figjam started as a direct fork of the [figaro](https://github.com/laserlemon/figaro) rubygem. Thanks
to @laserlemon for the great work on that gem.

There are some key differences in philosophy:

1. Figjam chooses not to go down the more "use ruby for configuration" 2.x path that gem was taking,
   preferring to keep using hierarchical yaml files.
2. Figjam prefers that you *do* commit your application.yml to your repository, as long as you don't
   put any credentials or other secrets in it. It encourages an ENV-with-code-change PR flow
   that simplifies providing default ENV values for an application, as well as codified 
   overrides per environment. These all, of course, can be overridden by a real ENV. 

Given (2), it doesn't make sense to push ENV to Heroku from the application.yml file, so Heroku
support has been removed.

With those caveats, it can be used as a drop-in replacement for the `figaro` gem.
It even aliases the `Figaro` to `Figjam` module namespace for drop-in compatibility.

## How can I help?

Figjam is open source and contributions from the community are encouraged! No
contribution is too small.

Jam jar image from https://vectorportal.com/
