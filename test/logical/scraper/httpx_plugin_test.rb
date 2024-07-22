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

    test "fetch_json doesn't raise when the response code is in the 200 range" do
      stub_request(:post, "https://example.com").to_return(body: "123", status: 201)
      json = @client.fetch_json("https://example.com", method: :post)
      assert_equal(123, json)
    end

    test "get doesn't raise if should_raise: false" do
      stub_request(:get, "https://example.com").to_return(status: 500, body: "OK")
      response = @client.get("https://example.com", should_raise: false)
      assert_equal(500, response.status)
      assert_equal("OK", response.body.to_s)
    end

    test "fetch_json doesn't raise if should_raise: false" do
      stub_request(:get, "https://example.com").to_return(status: 500, body: '{"status": "OK"}')
      json = @client.fetch_json("https://example.com", should_raise: false)
      assert_equal({ "status" => "OK" }, json)
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

    test "it logs options that are set on the session" do
      stub_request(:get, "https://example.com/test?foo=bar")
      @client.with(
        origin: "https://example.com",
        headers: { "x-a" => "a" },
      ).get("/test", headers: { "x-b" => "b" }, params: { foo: "bar" })

      payload = @submission_file.log_events.sole.payload
      assert_equal("https://example.com/test", payload["path"])
      assert_equal({
        "headers" => { "x-a" => "a", "x-b" => "b" },
        "params" => { "foo" => "bar" },
      }, payload["request_params"])
    end

    test "it logs json parameters" do
      stub_request(:post, "https://example.com").with(body: { foo: "bar" }.to_json)
      @client.post("https://example.com", json: { foo: "bar" })

      payload = @submission_file.log_events.sole.payload
      assert_equal("POST", payload["method"])
      assert_equal({ "json" => { "foo" => "bar" } }, payload["request_params"])
    end

    test "it doesn't log empty headers" do
      stub_request(:get, "https://example.com")
      @client.get("https://example.com")

      payload = @submission_file.log_events.sole.payload
      assert_empty(payload["request_params"])
    end
  end
end
