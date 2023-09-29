# frozen_string_literal: true

require "test_helper"

module Scraper
  class BaseTest < ActiveSupport::TestCase
    Sites.definitions.select { |s| s.is_a?(Sites::ScraperDefinition) }.each do |definition|
      test "#{definition.enum_value} has correct state" do
        scraper = stub_scraper_enabled(definition.enum_value) { definition.new_scraper(build(:artist_url)) }
        assert_respond_to(scraper.class, :state)
        assert(scraper.instance_variable_defined?(:"@#{scraper.class.state}"))
      end

      test "#{definition.enum_value} responds to required_config_keys" do
        scraper = stub_scraper_enabled(definition.enum_value) { definition.new_scraper(build(:artist_url)) }
        assert_respond_to(scraper.class, :required_config_keys)
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
        @scraper.expects(:tokens_old).twice.returns("value")

        @scraper.tokens
        Config.stubs(:twitter_user).returns("new_value")
        @scraper.tokens
        Config.unstub(:twitter_user)
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
