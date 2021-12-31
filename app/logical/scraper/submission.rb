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

      # No submission was created yet
      db_submission ||= ArtistSubmission.create!(
        artist_url: artist_url,
        identifier_on_site: identifier,
        title_on_site: title,
        description_on_site: description,
        created_at_on_site: created_at
      )
      last_scraped = artist_url.last_scraped_at
      still_to_download = last_scraped ? files.reject { |entry| entry[:created_at].before? last_scraped } : files
      return if still_to_download.count == 0

      CreateSubmissionWorker.perform_async db_submission.id, still_to_download, artist_url.site.enum_value
    end
  end
end
