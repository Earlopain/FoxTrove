# frozen_string_literal: true

require "test_helper"

module Scraper
  class HttpxPluginTest < ActiveSupport::TestCase
    setup do
      @submission_file = create(:submission_file)
      scraper = Scraper::Twitter.new(@submission_file)
      @client = HTTPX.plugin(Scraper::HttpxPlugin, scraper: scraper)
    end

    test "fetch_json returns a hash on success" do
      stub_request(:get, "https://example.com").to_return(body: { a: "b", c: "d" }.to_json)
      json = @client.fetch_json("https://example.com")
      assert_equal({ "a" => "b", "c" => "d" }, json)
    end

    test "fetch_json raises on error" do
      stub_request(:get, "https://example.com").to_return(status: 500)
      assert_raises(HTTPX::Error, match: "HTTP Error: 500") do
        @client.fetch_json("https://example.com")
      end
    end

    test "fetch_html returns a nokogiri doc" do
      stub_request(:get, "https://example.com").to_return(body: "<p>html fragment</p>")
      html = @client.fetch_html("https://example.com")
      assert_kind_of(Nokogiri::XML::Document, html)
      assert_match("html fragment", html)
    end

    test "it logs the responses" do
      stub_request(:get, "https://example.com?abc=def").to_return(body: "{}")
      @client.fetch_json("https://example.com", params: { abc: "def" })

      payload = @submission_file.log_events.sole.payload
      assert_equal({
        "path" => "https://example.com",
        "method" => "GET",
        "response_body" => "{}",
        "response_code" => 200,
        "request_params" => { "params" => { "abc" => "def" } },
      }, payload)
    end

    test "it logs the responses if it errors" do
      stub_request(:get, "https://example.com").to_return(status: 404)
      assert_raises(HTTPX::HTTPError) do
        @client.fetch_json("https://example.com")
      end
      assert_equal(404, @submission_file.log_events.sole.payload["response_code"])
    end
  end
end
