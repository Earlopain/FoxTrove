# frozen_string_literal: true

require "test_helper"

module Scraper
  class TwitterTest < ActiveSupport::TestCase
    def stubbed_scraper
      scraper = Scraper::Twitter.new(create(:artist_url))
      scraper.stubs(:tokens).returns(%w[auth_token csrf_token])
      scraper
    end

    it "filters out promoted tweets" do
      tweets = [
        json(:twitter_tweet, description: "user tweet"),
        json(:twitter_tweet, description: "promoted tweet", is_promoted: true),
      ]
      stub_request_once(:get, %r{GDQgpalPZYZohObq6Hsj-w/UserMedia}, body: json(:twitter_user_media, tweets: tweets))
      scraper = stubbed_scraper
      scraped_tweets = scraper.fetch_next_batch
      assert_equal(1, scraped_tweets.count)
      submission = scraper.to_submission(scraped_tweets[0])
      assert_equal("user tweet", submission.description)
    end
  end
end
