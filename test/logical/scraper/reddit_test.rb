# frozen_string_literal: true

require "test_helper"

module Scraper
  class RedditTest < ActiveSupport::TestCase
    setup do
      @scraper = Scraper::Reddit.new(create(:artist_url, url_identifier: "test"))
    end

    def stub_access_token_request
      stub_request(:post, "https://www.reddit.com/api/v1/access_token")
        .with(body: { grant_type: "client_credentials" }, headers: { authorization: "Basic Og==", user_agent: "reverser.0.1 by earlopain" })
        .to_return(body: { access_token: "very-secret" }.to_json)
    end

    test "it makes the correct requests to fetch api identifiers" do
      access_token_request = stub_access_token_request
      api_request = stub_request(:get, "https://oauth.reddit.com/user/test/about.json")
        .with(headers: { authorization: "bearer very-secret", user_agent: "reverser.0.1 by earlopain" })
        .to_return(body: { data: { id: 123 } }.to_json)

      id = @scraper.fetch_api_identifier
      assert_requested(access_token_request)
      assert_requested(api_request)
      assert_equal(123, id)
    end

    test "it makes the correct requests when fetching the next batch" do
      access_token_request = stub_access_token_request
      dummy_entries = [{ data: { domain: "i.redd.it" } }, { data: { domain: "what.ever" } }]
      api_request = stub_request(:get, "https://oauth.reddit.com/user/test/submitted.json?after&limit=100&show=all&sort=new")
        .to_return(body: { data: { children: dummy_entries } }.to_json)

      batch = @scraper.fetch_next_batch
      assert_requested(access_token_request)
      assert_requested(api_request)
      assert_equal(1, batch.size)
      assert_equal({ "domain" => "i.redd.it" }, batch.first)
    end
  end
end
