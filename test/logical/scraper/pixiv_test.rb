require "test_helper"

module Scraper
  class PixivTest < ActiveSupport::TestCase
    setup do
      @scraper = Scraper::Pixiv.new(create(:artist_url, url_identifier: "test"))
      @scraper.stubs(:fetch_code).returns("foo") # selenium
    end

    def stub_access_token_request(request_body, response)
      stub = stub_request(:post, Pixiv::AUTH_TOKEN_URL).with(body: hash_including(request_body))
        .to_return(response)
      yield
      assert_requested(stub, times: 1)
    ensure
      remove_request_stub(stub) if stub
    end

    test "token requests" do
      # Initial login
      request_body = { grant_type: "authorization_code" }
      response_body = { refresh_token: "refresh_1", access_token: "access_1", expires_in: 3600 }.to_json
      stub_access_token_request(request_body, { body: response_body }) do
        @scraper.access_token
        @scraper.access_token # nothing, still valid
      end

      assert_equal("access_1", @scraper.fetch_cache(Pixiv::ACCESS_TOKEN_KEY))
      assert_equal("refresh_1", @scraper.fetch_cache(Pixiv::REFRESH_TOKEN_KEY))

      # refresh token flow
      travel_to(2.hours.from_now) do
        request_body = { grant_type: "refresh_token", refresh_token: @scraper.fetch_cache(Pixiv::REFRESH_TOKEN_KEY) }
        response_body = { refresh_token: "refresh_2", access_token: "access_2", expires_in: 3600 }.to_json
        stub_access_token_request(request_body, { body: response_body }) do
          @scraper.access_token
          @scraper.access_token # nothing, still valid
        end

        assert_equal("access_2", @scraper.fetch_cache(Pixiv::ACCESS_TOKEN_KEY))
        assert_equal("refresh_2", @scraper.fetch_cache(Pixiv::REFRESH_TOKEN_KEY))
      end

      # invalid refresh token
      travel_to(4.hours.from_now) do
        request_body = { grant_type: "refresh_token", refresh_token: @scraper.fetch_cache(Pixiv::REFRESH_TOKEN_KEY) }
        stub_access_token_request(request_body, { body: "{}", status: 400 }) do
          assert_raises(Error, match: "failed to refresh access_token") do
            @scraper.access_token
          end
        end

        assert_nil(@scraper.fetch_cache(Pixiv::ACCESS_TOKEN_KEY))
        assert_nil(@scraper.fetch_cache(Pixiv::REFRESH_TOKEN_KEY))
      end
    end
  end
end
