require "test_helper"

class ScraperDefinitionTest < ActiveSupport::TestCase
  describe "scraper_enabled?" do
    it "returns true if all the required config keys are set" do
      definition = Sites.from_enum("twitter")
      stub_config(twitter_user: "a", twitter_pass: "b") do
        assert_empty(definition.missing_config_keys)
        assert_predicate(definition, :scraper_enabled?)
      end
    end

    it "returns false if the scraper is manually disabled" do
      definition = Sites.from_enum("twitter")
      stub_config(twitter_disabled?: true, twitter_user: "a", twitter_pass: "b") do
        assert_empty(definition.missing_config_keys)
        assert_not(definition.scraper_enabled?)
      end
    end

    it "returns false if a scraper config key is missing" do
      definition = Sites.from_enum("twitter")
      stub_config(twitter_user: "a") do
        assert_equal(%i[twitter_pass], definition.missing_config_keys)
        assert_not(definition.scraper_enabled?)
      end
    end
  end
end
