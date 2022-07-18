# frozen_string_literal: true

source "https://rubygems.org"

gem "bootsnap", ">= 1.4.4", require: false
gem "puma", "~> 5.5"
gem "rails", "~> 7.0"

gem "dalli"
gem "pg", "~> 1.1"
gem "sidekiq"
gem "sidekiq-unique-jobs"

gem "addressable"
gem "httparty"
gem "kaminari"
gem "nokogiri"
gem "responders"
gem "rotp"
gem "ruby-vips"
gem "selenium-webdriver"
gem "simple_form"

group :development, :test do
  gem "rspec-parameterized"
  gem "rspec-rails", "~> 5.0.0"
  gem "simplecov", require: false
end

group :development do
  gem "web-console"
end

group :rubocop, :local do
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-github-annotations-formatter", require: false
end

group :local do
  gem "solargraph", require: false
end
