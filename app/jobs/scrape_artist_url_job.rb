# frozen_string_literal: true

class ScrapeArtistUrlJob < ConcurrencyControlledJob
  queue_as :scraping
  good_job_control_concurrency_with(total_limit: 1, key: -> { arguments.first.id })

  def perform(artist_url) # rubocop:disable Metrics/CyclomaticComplexity
    return unless artist_url.scraper_enabled?

    scraper = artist_url.scraper
    scraper.jumpstart(artist_url.scraper_status[scraper.class.state.to_s]) if artist_url.scraper_status.present?
    artist_url.scraper_status["started_at"] ||= Time.current

    while scraper.more?
      submissions = scraper.fetch_and_save_next_submissions

      artist_url.update(scraper_status: artist_url.scraper_status.merge(scraper.class.state => scraper.state_value))

      break if submissions.any? { |submission| artist_url.scraper_stop_marker&.after?(submission.created_at) }
    end
    artist_url.last_scraped_at = artist_url.scraper_status["started_at"]
    artist_url.scraper_stop_marker = scraper.new_stop_marker
    artist_url.scraper_status = {}
    artist_url.save
  end
end
