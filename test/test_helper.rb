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
  # TODO: https://github.com/minitest-reporters/minitest-reporters/issues/330
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

    before do
      Config.stubs(:custom_config).returns({})
      Config.stubs(:env).returns({})
    end

    # https://github.com/minitest/minitest/issues/666
    def assert_equal(expected, actual, **)
      if expected.nil?
        assert_nil(actual)
      else
        super
      end
    end

    def stub_e6(post_id:, iqdb_matches: [], md5: "abc", &)
      iqdb_stub = stub_e6_iqdb_request([post_id] + iqdb_matches)
      post_stub = stub_e6_post_request(post_id, md5)
      yield
    ensure
      remove_request_stub(iqdb_stub) if iqdb_stub
      remove_request_stub(post_stub) if post_stub
    end

    private

    def stub_e6_iqdb_request(response_post_ids)
      response = json(:e6_iqdb_response, post_ids: response_post_ids)
      stub_request(:post, "https://e621.net/iqdb_queries.json")
        .to_return(body: response, headers: { "Content-Type" => "application/json" })
        .then.to_raise(ArgumentError.new("iqdb can only be stubbed once"))
    end

    def stub_e6_post_request(post_id, md5)
      response = json(:e6_post_response, post_id: post_id, md5: md5)
      stub_request(:get, "https://e621.net/posts/#{post_id}.json")
        .to_return(body: response, headers: { "Content-Type" => "application/json" })
    end
  end
end
