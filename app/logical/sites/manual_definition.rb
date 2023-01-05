# frozen_string_literal: true

module Sites
  class ManualDefinition < SimpleDefinition
    def gallery_url(identifier)
      identifier
    end

    def submission_url(submission)
      submission.identifier_on_site
    end

    def scraper_enabled?
      false
    end
  end
end
