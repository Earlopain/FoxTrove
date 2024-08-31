# frozen_string_literal: true

source "https://rubygems.org"

rails_version = "~> 7.2.0"
gem "actionpack",    rails_version
gem "actionview",    rails_version
gem "activejob",     rails_version
gem "activemodel",   rails_version
gem "activerecord",  rails_version
gem "activestorage", rails_version
gem "activesupport", rails_version
gem "railties",      rails_version

gem "addressable"
gem "good_job"
gem "httpx"
gem "listen"
gem "nokogiri"
gem "pagy"
gem "pg", "~> 1.1"
gem "puma"
gem "rotp"
gem "rouge"
gem "ruby-vips"
gem "rubyzip", "~> 2.4.rc1"
gem "rugged"
gem "selenium-webdriver"
gem "simple_form"

group :test do
  gem "simplecov", require: false
end

group :development, :test do
  gem "factory_bot", require: false
  gem "minitest-spec-rails", require: false
  gem "mocha", require: false
  gem "webmock", require: false
end

group :rubocop do
  gem "rubocop", require: false
  gem "rubocop-erb", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
end
