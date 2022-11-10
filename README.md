figjam
================

Simple, Heroku-friendly Rails app configuration using `ENV` and a single YAML file.

## Figjam origins

Figjam is a direct fork of the [figaro](https://github.com/laserlemon/figaro) rubygem.
However it chooses not to go down the more "ruby code" 2.x path that gem was taking, preferring to
keep using hierarchical yaml files.

It can be used as a direct drop-in for the `figaro` gem. It even aliases the `Figaro` to `Figjam`
module namespace for drop-in compatibility.

## Why does Figjam exist?

Figjam was written to make it easy to configure Rails applications.

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

Figjam installation is easy:

```bash
$ bundle exec figjam install
```

This creates a commented `config/application.yml` file and adds it to your
`.gitignore`. Add your own configuration to this file and you're done!

### Example

Given the following configuration file:

```yaml
# config/application.yml

pusher_app_id: "2954"
pusher_key: "7381a978f7dd7f9a1117"
pusher_secret: "abdc3b896a0ffb85d373"
```

You can configure [Pusher](http://pusher.com) in an initializer:

```ruby
# config/initializers/pusher.rb

Pusher.app_id = ENV["pusher_app_id"]
Pusher.key    = ENV["pusher_key"]
Pusher.secret = ENV["pusher_secret"]
```

**Please note:** `ENV` is a simple key/value store. All values will be converted
to strings. Deeply nested configuration structures are not possible.

### Environment-Specific Configuration

Oftentimes, local configuration values change depending on Rails environment. In
such cases, you can add environment-specific values to your configuration file:

```yaml
# config/application.yml

pusher_app_id: "2954"
pusher_key: "7381a978f7dd7f9a1117"
pusher_secret: "abdc3b896a0ffb85d373"

test:
  pusher_app_id: "5112"
  pusher_key: "ad69caf9a44dcac1fb28"
  pusher_secret: "83ca7aa160fedaf3b350"
```

You can also nullify configuration values for a specific environment:

```yaml
# config/application.yml

google_analytics_key: "UA-35722661-5"

test:
  google_analytics_key: ~
```

### Using `Figjam.env`

`Figjam.env` is a convenience that acts as a proxy to `ENV`.

In testing, it is sometimes more convenient to stub and unstub `Figjam.env` than
to set and reset `ENV`. Whether your application uses `ENV` or `Figjam.env` is
entirely a matter of personal preference.

```yaml
# config/application.yml

stripe_api_key: "sk_live_dSqzdUq80sw9GWmuoI0qJ9rL"
```

```ruby
ENV["stripe_api_key"] # => "sk_live_dSqzdUq80sw9GWmuoI0qJ9rL"
ENV.key?("stripe_api_key") # => true
ENV["google_analytics_key"] # => nil
ENV.key?("google_analytics_key") # => false

Figjam.env.stripe_api_key # => "sk_live_dSqzdUq80sw9GWmuoI0qJ9rL"
Figjam.env.stripe_api_key? # => true
Figjam.env.google_analytics_key # => nil
Figjam.env.google_analytics_key? # => false
```

### Required Keys

If a particular configuration value is required but not set, it's appropriate to
raise an error. With Figjam, you can either raise these errors proactively or
lazily.

To proactively require configuration keys:

```ruby
# config/initializers/figjam.rb

Figjam.require_keys("pusher_app_id", "pusher_key", "pusher_secret")
```

If any of the configuration keys above are not set, your application will raise
an error during initialization. This method is preferred because it prevents
runtime errors in a production application due to improper configuration.

To require configuration keys lazily, reference the variables via "bang" methods
on `Figjam.env`:

```ruby
# config/initializers/pusher.rb

Pusher.app_id = Figjam.env.pusher_app_id!
Pusher.key    = Figjam.env.pusher_key!
Pusher.secret = Figjam.env.pusher_secret!
```

### Deployment

Figjam is written with deployment in mind. In fact, [Heroku](https://www.heroku.com)'s
use of `ENV` for application configuration was the original inspiration for
Figjam.

#### Heroku

Heroku already makes setting application configuration easy:

```bash
$ heroku config:set google_analytics_key=UA-35722661-5
```

Using the `figjam` command, you can set values from your configuration file all
at once:

```bash
$ figjam heroku:set -e production
```

For more information:

```bash
$ figjam help heroku:set
```

#### Other Hosts

If you're not deploying to Heroku, you have two options:

* Generate a remote configuration file
* Set `ENV` variables directly

Generating a remote configuration file is preferred because of:

* familiarity – Management of `config/application.yml` is like that of `config/database.yml`.
* isolation – Multiple applications on the same server will not produce configuration key collisions.

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

### Heroku Configuration

```bash
$ figjam heroku:set -e production
```

For more information:

```bash
$ figjam help heroku:set
```

**NOTE:** The environment option is required for the `heroku:set` command. The
Rake task in Figjam 0.7 used the default of "development" if unspecified.

### Spring Configuration

If you're using Spring, either [stop](http://collectiveidea.com/blog/archives/2015/02/04/spring-is-dead-to-me)
or add `config/application.yml` to the watch list:

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
