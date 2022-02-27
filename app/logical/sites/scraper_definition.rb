module Sites
  class ScraperDefinition < SimpleDefinition
    def initialize(definition)
      super
      @submission_template = Addressable::Template.new(definition.submission_template)
      @scraper = "Scraper::#{enum_value.camelize}".constantize
    end

    def submission_url(submission)
      @submission_template.expand(site_artist_identifier: submission.artist_url.identifier_on_site,
                                  site_submission_identifier: submission.identifier_on_site).to_s
    end

    def scraper_enabled?
      @scraper.enabled? && !Config.send("#{enum_value}_disabled?")
    end

    def new_scraper(identifier)
      raise StandardError, "This scraper is not enabled!" unless scraper_enabled?

      @scraper.new(identifier: identifier)
    end
  end
end
