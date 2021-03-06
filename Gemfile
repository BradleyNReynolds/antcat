# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.5'

gem 'rails', '6.0.3.3'

gem 'citrus'
gem 'coffee-rails'
gem 'haml-rails'
gem 'mysql2'
gem 'puma', '< 5'
gem 'rack'
gem 'rack-cors'
gem 'rake'
gem 'request_store'
gem 'sass-rails', '5.1.0'
gem 'sprockets-rails', require: 'sprockets/railtie'
gem 'uglifier'

gem 'acts_as_list'
gem 'attr_extras'
gem 'aws-sdk', '< 3.0' # Version locked, see https://github.com/thoughtbot/paperclip/issues/2484
gem 'colorize'
gem 'config'
gem 'devise'
gem 'diffy', require: false
gem 'draper'
gem 'ey_config' # Required for accessing service configurations through `EY::Config` on EngineYard.
gem 'foundation-rails', '6.3.1.0'
gem 'grape-swagger-rails'
gem 'gretel'
gem 'high_voltage'
gem 'jquery-atwho-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'ledermann-rails-settings'
gem 'newrelic_rpm'
gem 'paperclip', '5.3.0'
gem 'paper_trail', '~> 11.0'
gem 'rails-observers'
gem 'redcarpet'
gem 'ruby-progressbar'
gem 'select2-rails'
gem 'strip_attributes'
gem 'strong_migrations'
gem 'sunspot_rails'
gem 'sunspot_solr', '2.2.0'
gem 'twitter-typeahead-rails'
gem 'unread'
gem 'will_paginate'
gem 'workflow-activerecord'

group :development do
  gem 'awesome_print', require: 'ap'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'rubycritic', require: false
  gem 'tabulo'
end

group :development, :test do
  gem 'email_spec'
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'haml_lint', require: false
  gem 'pry'
  gem 'rspec-rails'
  gem 'rubocop', '0.93', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'sunspot_test',
    git: 'https://github.com/jonkerz/sunspot_test.git',
    ref: 'f72d876062b4ea5bae7e6ef194b859cd9f38ae1b'
end

group :test do
  gem 'apparition'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'webmock'
end

# Uncomment for profiling.
# gem 'rack-mini-profiler'
