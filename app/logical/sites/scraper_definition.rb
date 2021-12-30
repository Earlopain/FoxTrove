module Sites
  class ScraperDefinition < SimpleDefinition
    attr_accessor :scraper

    def initialize(definition)
      super
      @submission_template = Addressable::Template.new(definition.submission_template)
      @scraper = "Scraper::#{enum_value.camelize}".constantize
    end

    def submission_url(submission)
      @submission_template.expand(site_artist_identifier: submission.artist_url.identifier_on_site,
                                  site_submission_identifier: submission.identifier_on_site).to_s
    end
  end
end
