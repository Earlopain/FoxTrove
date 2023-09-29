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
  end
end
