# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["MT_NO_EXPECTATIONS"] ||= "1"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/rails"
require "minitest/reporters"

require "factory_bot_rails"
require "mocha/minitest"
require "webmock/minitest"

if ENV["CI"]
  Minitest::Reporters.use! Minitest::Reporters::JUnitReporter.new
else
  Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new
end

FactoryBot::SyntaxRunner.class_eval do
  include ActiveSupport::Testing::FileFixtures
  self.file_fixture_path = ActiveSupport::TestCase.file_fixture_path
end

WebMock.disable_net_connect!

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # What a stupid hill to die on. Supresses a deprecation warning
    # https://github.com/minitest/minitest/issues/666
    def assert_equal(expected, actual, **)
      if expected.nil?
        assert_nil(actual)
      else
        super
      end
    end
  end
end
