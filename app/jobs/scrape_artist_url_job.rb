# frozen_string_literal: true

class ScrapeArtistUrlJob < ApplicationJob
  queue_as :scraping

  def perform(artist_url) # rubocop:disable Metrics/CyclomaticComplexity
    return unless artist_url.scraper_enabled?

    scraper = artist_url.scraper
    scraper.jumpstart(artist_url.scraper_status[scraper.class.state.to_s]) if artist_url.scraper_status.present?
    artist_url.scraper_status["started_at"] ||= Time.current

    while scraper.more?
      submissions = scraper.fetch_and_save_next_submissions

      artist_url.update(scraper_status: artist_url.scraper_status.merge(scraper.class.state => scraper.state_value))

      stop_marker = artist_url.last_scraped_at
      break if stop_marker.present? && submissions.any? { |submission| submission.created_at.before? stop_marker }
    end
    artist_url.last_scraped_at = artist_url.scraper_status["started_at"]
    artist_url.scraper_status = {}
    artist_url.save
  end
end
