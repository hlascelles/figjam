if ::Gem::Version.new(RUBY_VERSION) <= ::Gem::Version.new("3.3")
  appraise "rails-6" do
    gem "psych", "~> 4.0"
    gem "sqlite3", "~> 1.0"
    gem "rails", "~> 6.0.3"
  end

  appraise "rails-6-1" do
    gem "psych", "~> 4.0"
    gem "sqlite3", "~> 1.0"
    gem "rails", "~> 6.1.0"
  end
end

appraise "rails-7" do
  gem "sqlite3", "~> 1.0"
  gem "rails", "~> 7.0"
end

appraise "psych-4.0" do
  gem "sqlite3", "~> 1.0"
  gem "rails", "~> 7.0"
  gem "psych", "~> 4.0"
end

appraise "psych-5.0" do
  gem "sqlite3", "~> 1.0"
  gem "rails", "~> 7.0"
  gem "psych", "~> 5.0"
end

appraise "rails-8" do
  gem "sqlite3", "~> 2.0"
  gem "rails", "~> 8.0"
end
