module Scraper
  class Submission
    attr_accessor :identifier, :created_at, :title, :description, :files

    def initialize
      @files = []
    end

    def save(artist_url)
      artist_submission = ArtistSubmission.find_by(
        artist_url: artist_url,
        identifier_on_site: identifier
      )

      # No submission was created yet
      artist_submission ||= ArtistSubmission.create!(
        artist_url: artist_url,
        identifier_on_site: identifier,
        title_on_site: title,
        description_on_site: description,
        created_at_on_site: created_at
      )

      files.each do |file|
        CreateSubmissionFileWorker.perform_async artist_submission.id, file[:identifier], file[:created_at], file[:url], artist_url.site.enum_value
      end
    end
  end
end
