require "test_helper"

module Scraper
  class TwitterTest < ActiveSupport::TestCase
    USER_MEDIA = %r{oMVVrI5kt3kOpyHHTTKf5Q/UserMedia}

    def scraper
      @scraper ||= begin
        scraper = Scraper::Twitter.new(create(:artist_url))
        scraper.stubs(:tokens).returns(%w[auth_token csrf_token])
        scraper
      end
    end

    it "filters out promoted tweets" do
      tweets = [
        build(:twitter_tweet, description: "user tweet"),
        build(:twitter_tweet, description: "promoted tweet", is_promoted: true),
      ]
      stub_request_once(:get, USER_MEDIA, body: build(:twitter_user_media_page1, tweets: tweets).to_json)
      scraped_tweets = scraper.fetch_next_batch
      assert_equal(1, scraped_tweets.count)
      submission = scraper.to_submission(scraped_tweets[0])
      assert_equal("user tweet", submission.description)
      assert_predicate(scraper, :more?)
    end

    it "returns results for the second page" do
      tweet = build(:twitter_tweet)
      stub_request_once(:get, USER_MEDIA, body: build(:twitter_user_media_page2, tweets: [tweet]).to_json)
      scraped_tweets = scraper.fetch_next_batch
      assert_equal(1, scraped_tweets.count)
      assert_predicate(scraper, :more?)
    end

    it "stops once the end is reached" do
      stub_request_once(:get, USER_MEDIA, body: build(:twitter_user_media_last_page).to_json)
      assert_empty(scraper.fetch_next_batch)
      assert_not_predicate(scraper, :more?)
    end

    it "correctly expands shortened links when replying" do
      # https://twitter.com/Vorpaliar/status/1634596427279024133
      url = build(:twitter_url_entity,
        short_url: "https://t.co/mWjLGrVFzq",
        long_url: "https://www.furaffinity.net/commissions/vorpale/",
        start: 67,
        stop: 90,
      )
      tweet = build(:twitter_tweet,
        description: "@Idunndesable J'ai de la place pour le mois prochain si tu veux ♥ \nhttps://t.co/mWjLGrVFzq https://t.co/CverijgMUs",
        description_start: 14,
        description_end: 90,
        url_entities: [url],
      )
      stub_request_once(:get, USER_MEDIA, body: build(:twitter_user_media_page1, tweets: [tweet]).to_json)
      scraped_tweets = scraper.fetch_next_batch
      submission = scraper.to_submission(scraped_tweets[0])
      assert_equal("J'ai de la place pour le mois prochain si tu veux ♥ \nhttps://www.furaffinity.net/commissions/vorpale/", submission.description)
    end

    it "returns an empty description if full_text contains just a link to the tweet itself" do
      # https://twitter.com/loafyfloff/status/702649634297020418
      media = build(:twitter_photo_media, short_url: "qnaX4IfMNP")
      tweet = build(:twitter_tweet,
        description: "https://t.co/qnaX4IfMNP",
        description_start: 0,
        description_end: 23,
        media: [media],
      )
      stub_request_once(:get, USER_MEDIA, body: build(:twitter_user_media_page1, tweets: [tweet]).to_json)
      scraped_tweets = scraper.fetch_next_batch
      submission = scraper.to_submission(scraped_tweets[0])
      assert_equal("", submission.description)
    end

    it "correctly truncates the description" do
      # https://twitter.com/BDMon_18/status/1611845505084198912
      media = build(:twitter_photo_media, short_url: "Z83jgnJz0x")
      tweet = build(:twitter_tweet,
        description: "Commission for @LaxyVRC 🦊 https://t.co/Z83jgnJz0x",
        description_start: 0,
        description_end: 25,
        media: [media],
      )
      stub_request_once(:get, USER_MEDIA, body: build(:twitter_user_media_page1, tweets: [tweet]).to_json)
      scraped_tweets = scraper.fetch_next_batch
      submission = scraper.to_submission(scraped_tweets[0])
      assert_equal("Commission for @LaxyVRC 🦊", submission.description)
    end
  end
end
