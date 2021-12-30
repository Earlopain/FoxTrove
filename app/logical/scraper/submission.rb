module Scraper
  class Submission
    attr_accessor :identifier, :created_at, :title, :description, :files

    def initialize
      @files = []
    end

    def save(artist_url)
      db_submission = ArtistSubmission.find_by(
        artist_url: artist_url,
        identifier_on_site: identifier
      )
      # There are already files downloaded, no need to do that again
      return if db_submission&.submission_files&.count.to_i.positive?

      # No submission was created yet
      db_submission ||= ArtistSubmission.create!(
        artist_url: artist_url,
        identifier_on_site: identifier,
        title_on_site: title,
        description_on_site: description,
        created_at_on_site: created_at
      )
      CreateSubmissionWorker.perform_async db_submission.id, files, artist_url.site.enum_value
    end
  end
end
