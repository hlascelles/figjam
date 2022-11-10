figjam
================

Simple, Rails app configuration using `ENV` and a single YAML file.

## Figjam origins

Figjam started as a direct fork of the [figaro](https://github.com/laserlemon/figaro) rubygem.

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

## Why does Figjam exist?

Figjam makes it easy to configure Rails applications.

PRs to applications often need to come with default configuration values, but hardcoding these into
software makes them impossible to change at runtime. However supplying them separately to an
orchestration framework introduces deploy coordination that can be tricky to get right.

Figjam encourages you to commit default ENV values to a yaml file in your PRs. These are then
loaded at runtime, but, crucially, can be overridden at any time by supplying a real ENV. This
brings the ease of PR creation with the flexibility of runtime ENV changes.

### Getting Started

Add Figjam to your Gemfile and `bundle install`:

```ruby
gem "figjam"
```

Then:

```bash
$ bundle exec figjam install
```

This creates a commented `config/application.yml` file which you can add default ENV to.
Add your own configuration to this file for all environments, and any specific environment
overrides.

### Example

Given the following configuration file, the default value at the top will be used unless
RAILS_ENV matches any of the subsequent keys (like `test`, `prelive`, `produciton`).

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
Note, secrets are not to be provided by figjam.

eg:
```
# app/views/layouts/application.html.erb

<script>
var gtm_id = <%= ENV.fetch("GOOGLE_TAG_MANAGER_ID") %> 
</script>
```

**Please note:** `ENV` is a simple key/value store. All values will be converted
to strings. Deeply nested configuration structures are not possible.

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
# config/initializers/pusher.rb

Pusher.app_id = Figjam.env.google_tag_manager_id!
```

## Is Figjam like [dotenv](https://github.com/bkeepers/dotenv)?

Yes. Kind of.

Figjam and dotenv were written around the same time to solve similar problems.

### Similarities

* Both libraries are useful for Ruby application configuration.
* Both are popular and well maintained.
* Both are inspired by Twelve-Factor App's concept of proper [configuration](http://12factor.net/config).
* Both store configuration values in `ENV`.

### Differences

* Configuration File
  * Figjam expects a single file.
  * Dotenv supports separate files for each environment.
* Configuration File Format
  * Figjam expects YAML containing key/value pairs.
  * Dotenv convention is a collection of `KEY=VALUE` pairs.
* Security vs. Convenience
  * Figjam convention is to never commit configuration files.
  * Dotenv encourages committing configuration files containing development values.
* Framework Focus
  * Figjam was written with a focus on Rails development and conventions.
  * Dotenv was written to accommodate any type of Ruby application.

Either library may suit your configuration needs. It often boils down to
personal preference.

## Is application.yml like [secrets.yml](https://github.com/rails/rails/blob/v4.1.0/railties/lib/rails/generators/rails/app/templates/config/secrets.yml)?

Yes. Kind of.

Rails 4.1 introduced the `secrets.yml` convention for Rails application
configuration. Figjam predated the Rails 4.1 release by two years.

### Similarities

* Both are useful for Rails application configuration.
* Both are popular and well maintained.
* Both expect a single YAML file.

### Differences

* Configuration Access
  * Figjam stores configuration values in `ENV`.
  * Rails stores configuration values in `Rails.application.secrets`.
* Configuration File Structure
  * Figjam expects YAML containing key/value string pairs.
  * Secrets may contain nested structures with rich objects.
* Security vs. Convenience
  * Figjam convention is to never commit configuration files.
  * Secrets are committed by default.
* Consistency
  * Figjam uses `ENV` for configuration in every environment.
  * Secrets encourage using `ENV` for production only.
* Approach
  * Figjam is inspired by Twelve-Factor App's concept of proper [configuration](http://12factor.net/config).
  * Secrets are… not.

The emergence of a configuration convention for Rails is an important step, but
as long as the last three differences above exist, Figjam will continue to be
developed as a more secure, more consistent, and more standards-compliant
alternative to `secrets.yml`.

### Spring Configuration

If you're using Spring add `config/application.yml` to the watch list:

```rb
# config/spring.rb

%w(
  ...
  config/application.yml
).each { |path| Spring.watch(path) }
```

## How can I help?

Figjam is open source and contributions from the community are encouraged! No
contribution is too small.
