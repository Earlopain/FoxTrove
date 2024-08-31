require "test_helper"

module Scraper
  class BaseTest < ActiveSupport::TestCase
    Sites.scraper_definitions.each do |definition|
      test "#{definition.site_type} has correct state" do
        scraper = stub_scraper_enabled(definition.site_type) { definition.new_scraper(build(:artist_url)) }
        assert(scraper.class.const_defined?(:STATE))
        assert(scraper.instance_variable_defined?(:"@#{scraper.class::STATE}"))
      end
    end

    describe "process!" do
      it "stops once no more results are returned" do
        artist_url = create(:artist_url, url_identifier: "foo", api_identifier: 123, scraper_stop_marker: 10.hours.ago)
        scraper = Scraper::Artstation.new(artist_url)
        scraper.stubs(:fetch_next_batch).returns([
          {
            "hash_id" => "bar",
            "title" => "baz",
            "description" => "hello!",
            "created_at" => 15.hours.ago.to_s,
            "updated_at" => 15.hours.ago.to_s,
            "assets" => [],
          },
        ])
        scraper.process!
        assert_in_delta Time.current, artist_url.reload.last_scraped_at, 1
      end

      it "continues if an old submission has been updated" do
        artist_url = create(:artist_url, url_identifier: "foo", api_identifier: 123, scraper_stop_marker: 10.hours.ago)
        scraper = Scraper::Artstation.new(artist_url)
        b1 = {
          "hash_id" => "bar1",
          "title" => "baz",
          "description" => "hello!",
          "created_at" => 15.hours.ago.to_s,
          "updated_at" => 5.hours.ago.to_s,
          "assets" => [],
        }
        b2 = {
          "hash_id" => "bar2",
          "title" => "baz",
          "description" => "hello!",
          "created_at" => 15.hours.ago.to_s,
          "updated_at" => 15.hours.ago.to_s,
          "assets" => [],
        }
        scraper.stubs(:fetch_next_batch).returns([b1]).then.returns([b2])
        scraper.process!
        assert_equal(2, artist_url.submissions.count)
      end
    end

    describe "config keys" do
      it "returns the correct values for inheritance chains" do
        assert_equal(%i[baraag_access_token], Scraper::Baraag.required_config_keys)
      end

      it "doesn't return optional config keys" do
        assert_equal(%i[twitter_user twitter_pass], Scraper::Twitter.required_config_keys)
      end

      it "returns an empty array when there are no necessary keys" do
        assert_empty(Scraper::Piczel.required_config_keys)
      end

      it "returns the correct values for all config keys" do
        assert_equal(%i[twitter_user twitter_pass twitter_otp_secret twitter_disabled?], Scraper::Twitter.all_config_keys)
      end

      it "returns the correct values for optional config keys" do
        assert_equal(%i[twitter_otp_secret], Scraper::Twitter.optional_config_keys)
        assert_empty(Scraper::Piczel.optional_config_keys)
      end
    end

    describe "caching" do
      setup do
        @scraper = Scraper::Twitter.new(create(:artist_url))
      end

      it "is stable" do
        assert_equal("Scraper::Twitter.foo/7d010443693eec253a121e2aa2ba177c", @scraper.class.cache_key("foo"))
      end

      it "calls the original method only once" do
        @scraper.expects(:tokens_old).once.returns("value")

        @scraper.tokens
        @scraper.tokens
      end

      it "doesn't cache nil" do
        @scraper.expects(:tokens_old).twice.returns(nil)

        @scraper.tokens
        @scraper.tokens
      end

      it "invalidates the cache when config values change" do
        @scraper.expects(:tokens_old).times(3).returns("value")

        @scraper.tokens
        Config.stubs(:twitter_user).returns("new_value")
        @scraper.tokens
        Config.unstub(:twitter_user)
        @scraper.tokens
        Config.stubs(:twitter_otp_secret).returns("new_value")
        @scraper.tokens
      end

      it "correctly removes the currently cached value" do
        @scraper.expects(:tokens_old).twice.returns("value")

        @scraper.tokens
        @scraper.class.delete_cache(:tokens)
        @scraper.tokens
      end
    end
  end
end
