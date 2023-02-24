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
    def assert_equal(expected, actual, message = nil, **)
      if expected.nil?
        assert_nil(actual, message)
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

    def stub_scraper_enabled(*site_types, &)
      sites = site_types.map { |site_type| Sites.from_enum(site_type.to_s) }
      sites.each.with_index do |site, index|
        raise ArgumentError, "#{site_types[index]} is not a valid scraper" unless site.is_a?(Sites::ScraperDefinition)

        site.stubs(:scraper_enabled?).returns(true)
      end
      yield
    ensure
      sites.each { |site| site.unstub(:scraper_enabled?) }
    end

    def stub_request_once(method, url_matcher, body:, content_type: nil)
      stub_request(method, url_matcher)
        .to_return(body: body.to_json, headers: { "Content-Type" => content_type })
        .then.to_raise(ArgumentError.new("can only be stubbed once"))
    end

    private

    def stub_e6_iqdb_request(response_post_ids)
      response = json(:e6_iqdb_response, post_ids: response_post_ids)
      stub_request_once(:post, "https://e621.net/iqdb_queries.json", body: response, content_type: "application/json")
    end

    def stub_e6_post_request(post_id, md5)
      response = json(:e6_post_response, post_id: post_id, md5: md5)
      stub_request_once(:get, "https://e621.net/posts/#{post_id}.json", body: response, content_type: "application/json")
    end
  end
end
