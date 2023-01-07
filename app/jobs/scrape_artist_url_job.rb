# frozen_string_literal: true

class ScrapeArtistUrlJob < ApplicationJob
  queue_as :scraping
  good_job_control_concurrency_with(total_limit: 1, key: -> { arguments.first })

  def perform(artist_url_id)
    artist_url = ArtistUrl.find_by id: artist_url_id
    return unless artist_url&.scraper_enabled?

    scraper = artist_url.scraper
    while scraper.more?
      submissions = scraper.fetch_and_save_next_submissions
      stop_marker = artist_url.last_scraped_at
      break if stop_marker.present? && submissions.any? { |submission| submission.created_at.before? stop_marker }
    end
    artist_url.last_scraped_at = Time.current
    artist_url.save
  end
end
