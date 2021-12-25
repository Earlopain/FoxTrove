class ScrapeArtistUrlWorker
  include Sidekiq::Worker

  sidekiq_options queue: :scraping, lock: :until_executed, lock_ttl: 1.hour, on_conflict: :log

  def perform(artist_url_id)
    artist_url = ArtistUrl.find_by id: artist_url_id
    return unless artist_url

    scraper = artist_url.site.scraper.new
    scraper.scrape!(identifier: artist_url.identifier_on_site).each do |submission|
      db_submission = ArtistSubmission.find_by(
        artist_url: artist_url,
        identifier_on_site: submission.identifier
      )
      # There are already files downloaded, no need to do that again
      next if db_submission&.submission_files&.count.to_i.positive?

      # No submission was created yet
      db_submission ||= ArtistSubmission.create!(
        artist_url: artist_url,
        identifier_on_site: submission.identifier,
        title_on_site: submission.title,
        description_on_site: submission.description,
        created_at_on_site: submission.created_at
      )
      CreateSubmissionWorker.perform_async db_submission.id, submission.files, artist_url.site.enum_value
    end
  end
end
