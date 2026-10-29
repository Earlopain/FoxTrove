module Sites
  class ManualDefinition < SimpleDefinition
    def gallery_url(artist_url)
      artist_url.unescaped_url_identifier
    end

    def submission_url(submission)
      submission.identifier_on_site
    end

    def match_for_gallery(_uri)
      # Do nothing
    end
  end
end
