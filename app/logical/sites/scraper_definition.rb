module Sites
  class ScraperDefinition < SimpleDefinition
    attr_accessor :scraper

    def initialize(enum_value:, display_name:, homepage:, gallery_templates:,
                   username_identifier_regex:, submission_template:)
      # TODO: https://bugs.ruby-lang.org/issues/14579 on ruby 3.1 release
      super(enum_value: enum_value, display_name: display_name, homepage: homepage,
            gallery_templates: gallery_templates, username_identifier_regex: username_identifier_regex)
      @submission_template = Addressable::Template.new(submission_template)
      @scraper = "Scraper::#{enum_value.camelize}".constantize
    end

    def submission_url(submission)
      @submission_template.expand(site_artist_identifier: submission.artist_url.identifier_on_site,
                                  site_submission_identifier: submission.identifier_on_site).to_s
    end
  end
end