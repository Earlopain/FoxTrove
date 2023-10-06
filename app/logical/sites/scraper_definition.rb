# frozen_string_literal: true

module Sites
  class ScraperDefinition < SimpleDefinition
    attr_reader :submission_template

    def initialize(definition_data)
      super
      @submission_template = Addressable::Template.new(definition_data["submission_template"])
      @image_domains = definition_data["image_domains"] || []
      @download_headers = definition_data["download_headers"] || {}
      @scraper = "Scraper::#{site_type.camelize}".constantize
    end

    def submission_url(submission)
      submission_template.expand(
        site_artist_identifier: submission.artist_url.url_identifier,
        site_submission_identifier: submission.identifier_on_site,
      ).to_s
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
      Config.send("#{site_type}_disabled?")
    end

    def scraper_enabled?
      missing_config_keys.none? && !manually_disabled?
    end

    def new_scraper(artist_url)
      raise StandardError, "This scraper is not enabled!" unless scraper_enabled?

      @scraper.new artist_url
    end
  end
end
