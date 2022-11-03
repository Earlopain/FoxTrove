# frozen_string_literal: true

module Sites
  class ScraperDefinition < SimpleDefinition
    attr_reader :submission_template

    def initialize(definition_data)
      super
      @submission_template = Addressable::Template.new(definition_data["submission_template"])
      @image_domains = definition_data["image_domains"] || []
      @download_headers = definition_data["download_headers"] || {}
      @scraper = "Scraper::#{enum_value.camelize}".constantize
    end

    def submission_url(submission)
      submission_template.expand(
        site_artist_identifier: submission.artist_url.url_identifier,
        site_submission_identifier: submission.identifier_on_site,
      ).to_s
    end

    def scraper_enabled?
      @scraper.enabled? && !Config.send("#{enum_value}_disabled?")
    end

    def new_scraper(artist_url)
      raise StandardError, "This scraper is not enabled!" unless scraper_enabled?

      s = @scraper.new artist_url
      s.init
      s
    end
  end
end
