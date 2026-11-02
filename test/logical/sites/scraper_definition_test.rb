require "test_helper"

class ScraperDefinitionTest < ActiveSupport::TestCase
  setup do
    Config.stubs(:custom_config).returns({})
  end

  test "#scraper_enabled? returns true if all the required config keys are set" do
    Config.stubs(:twitter_user).returns("a")
    Config.stubs(:twitter_pass).returns("b")

    definition = Sites.from_enum("twitter")

    assert_empty(definition.missing_config_keys)
    assert_predicate(definition, :scraper_enabled?)
  end

  test "#scraper_enabled? returns false if the scraper is manually disabled" do
    Config.stubs(:twitter_disabled?).returns(true)
    Config.stubs(:twitter_user).returns("a")
    Config.stubs(:twitter_pass).returns("b")

    definition = Sites.from_enum("twitter")

    assert_empty(definition.missing_config_keys)
    assert_not(definition.scraper_enabled?)
  end

  test "#scraper_enabled? returns false if a scraper config key is missing" do
    Config.stubs(:twitter_user).returns("a")

    definition = Sites.from_enum("twitter")

    assert_equal(%i[twitter_pass], definition.missing_config_keys)
    assert_not(definition.scraper_enabled?)
  end

  test "#cached_values returns all active cache keys" do
    definition = Sites.from_enum("pixiv")
    Scraper::Pixiv::CACHE_KEYS.each_with_index do |key, index|
      Scraper::Pixiv.fetch_cache(key) { index }
    end

    assert_equal({ "refresh_token" => 0, "access_token" => 1 }, definition.cached_values)
  end
end
