# frozen_string_literal: true

module Sites
  class ScraperDefinition < SimpleDefinition
    def initialize(definition_data)
      super
      @scraper = "Scraper::#{site_type.camelize}".constantize
    end

    def missing_config_keys
      @scraper.required_config_keys.select { |key| Config.send(key).blank? }
    end

    delegate :all_config_keys, to: :@scraper

    def cached_values
      @scraper.cached_methods.filter_map do |method|
        key = @scraper.cache_key(method)
        next unless Rails.cache.exist?(key)

        [method, Rails.cache.fetch(key)]
      end.to_h
    end

    def manually_disabled?
      Config.send(:"#{site_type}_disabled?")
    end

    def scraper_enabled?
      missing_config_keys.none? && !manually_disabled?
    end

    def scraper?
      true
    end

    def new_scraper(artist_url)
      raise StandardError, "This scraper is not enabled!" unless scraper_enabled?

      @scraper.new artist_url
    end
  end
end
