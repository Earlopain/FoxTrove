# frozen_string_literal: true

source "https://rubygems.org"

gem "puma", "~> 5.5"
gem "rails", "~> 7.0"

gem "good_job"
gem "pg", "~> 1.1"

gem "addressable"
gem "draper"
gem "httparty"
gem "kaminari"
gem "listen"
gem "nokogiri"
gem "open3"
gem "responders"
gem "rotp"
gem "ruby-vips"
gem "selenium-webdriver"
gem "simple_form"

group :development, :test do
  gem "factory_bot_rails", require: false
  gem "minitest-rails", require: false
  gem "minitest-reporters", git: "https://github.com/earlopain/minitest-reporters.git", ref: "2377272727265267f25a2d8cf73e31a7a121e745", require: false
  gem "mocha", require: false
  gem "webmock", require: false
end

group :rubocop do
  gem "rubocop", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
end

group :local do
  gem "solargraph", require: false
end
