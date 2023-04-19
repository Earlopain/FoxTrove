# frozen_string_literal: true

require "test_helper"

class ScraperDefinitionTest < ActiveSupport::TestCase
  describe "scraper_enabled?" do
    it "returns true if all the required config keys are set" do
      Config.stubs(:twitter_user).returns("a")
      Config.stubs(:twitter_pass).returns("b")

      definition = Sites.from_enum("twitter")

      assert_empty(definition.missing_config_keys)
      assert(definition.scraper_enabled?)
    end

    it "returns false if the scraper is manually disabled" do
      Config.stubs(:twitter_disabled?).returns(true)
      Config.stubs(:twitter_user).returns("a")
      Config.stubs(:twitter_pass).returns("b")

      definition = Sites.from_enum("twitter")

      assert_empty(definition.missing_config_keys)
      assert_not(definition.scraper_enabled?)
    end

    it "returns false if a scraper config key is missing" do
      Config.stubs(:twitter_user).returns("a")

      definition = Sites.from_enum("twitter")

      assert_equal(%i[twitter_pass], definition.missing_config_keys)
      assert_not(definition.scraper_enabled?)
    end
  end
end
