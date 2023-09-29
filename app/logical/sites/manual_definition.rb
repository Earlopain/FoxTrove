# frozen_string_literal: true

module Sites
  class ManualDefinition < SimpleDefinition
    def gallery_url(identifier)
      identifier
    end

    def submission_url(submission)
      submission.identifier_on_site
    end

    def missing_config_keys
      []
    end

    def cached_values
      {}
    end

    def manually_disabled?
      false
    end

    def scraper_enabled?
      false
    end

    def match_for_gallery(_uri)
      # Do nothing
    end
  end
end
