# frozen_string_literal: true

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

    describe "required_config_keys" do
      it "returns the correct values for inheritance chains" do
        assert_equal(%i[baraag_access_token], Scraper::Baraag.required_config_keys)
      end

      it "doesn't return optional config keys" do
        assert_equal(%i[twitter_user twitter_pass], Scraper::Twitter.required_config_keys)
      end

      it "returns an empty array when there are no necessary keys" do
        assert_empty(Scraper::Piczel.required_config_keys)
      end
    end

    describe "caching" do
      setup do
        @scraper = Scraper::Twitter.new(create(:artist_url))
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
