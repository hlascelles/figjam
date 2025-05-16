source "https://rubygems.org"

gemspec

# Required for Rails 6 bug. Can be removed when only on Rails 7 and above
# See https://stackoverflow.com/a/70500221/1267203
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", require: false

group :development, :test do
  gem "fasterer"
  gem "pry-byebug"
  gem "rake"
  gem "reek"
  gem "rspec"
  gem "rubocop"
  gem "rubocop-magic_numbers"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rake", "> 0.7.0" # as plugin
  gem "rubocop-rspec", "> 3.5.0" # as plugin
  gem "rubocop-thread_safety"
end
