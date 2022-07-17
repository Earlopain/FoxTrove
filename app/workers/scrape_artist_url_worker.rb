# frozen_string_literal: true

class ScrapeArtistUrlWorker
  include Sidekiq::Worker

  sidekiq_options queue: :scraping, lock: :until_executed, lock_ttl: 1.hour, on_conflict: :log

  def perform(artist_url_id)
    artist_url = ArtistUrl.find_by id: artist_url_id
    return unless artist_url&.scraper_enabled?

    scraper = artist_url.site.new_scraper(artist_url)
    while scraper.more?
      submissions = scraper.fetch_and_save_next_submissions(artist_url)
      stop_marker = artist_url.last_scraped_at
      scraper.end_reached if stop_marker.present? && submissions.any? { |submission| submission.created_at.before? stop_marker }
    end
    artist_url.last_scraped_at = Time.current
    artist_url.save
  end
end
