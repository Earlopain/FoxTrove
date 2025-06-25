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
        scraper.stub(:fetch_next_batch, [
          {
            "hash_id" => "bar",
            "title" => "baz",
            "description" => "hello!",
            "created_at" => 15.hours.ago.to_s,
            "updated_at" => 15.hours.ago.to_s,
            "assets" => [],
          },
        ]) do
          scraper.process!
        end
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
        batches = [b1, b2]
        scraper.stub(:fetch_next_batch, -> { [batches.shift] }) do
          scraper.process!
        end
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

      def assert_called(object, method_name, returns:, times:, &)
        called = 0
        object.stub(method_name, -> {
          called += 1
          returns
        }, &)

        assert_equal(times, called, "Expected #{method_name} to be called #{times} times, but was called #{called} times")
      end

      it "is stable" do
        assert_equal("Scraper::Twitter.foo/7d010443693eec253a121e2aa2ba177c", @scraper.class.cache_key("foo"))
      end

      it "calls the original method only once" do
        assert_called(@scraper, :tokens_old, returns: "value", times: 1) do
          @scraper.tokens
          @scraper.tokens
        end
      end

      it "doesn't cache nil" do
        assert_called(@scraper, :tokens_old, returns: nil, times: 2) do
          @scraper.tokens
          @scraper.tokens
        end
      end

      it "invalidates the cache when config values change" do
        assert_called(@scraper, :tokens_old, returns: "value", times: 3) do
          @scraper.tokens
          stub_config(twitter_user: "new_value") do
            @scraper.tokens
          end
          @scraper.tokens
          stub_config(twitter_otp_secret: "new_value") do
            @scraper.tokens
          end
        end
      end

      it "correctly removes the currently cached value" do
        assert_called(@scraper, :tokens_old, returns: "value", times: 2) do
          @scraper.tokens
          @scraper.class.delete_cache(:tokens)
          @scraper.tokens
        end
      end
    end
  end
end
