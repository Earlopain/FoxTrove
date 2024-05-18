# frozen_string_literal: true

class ScrapeArtistUrlJob < ConcurrencyControlledJob
  queue_as :scraping
  good_job_control_concurrency_with(total_limit: 1, key: -> { arguments.first.id })

  def perform(artist_url)
    return unless artist_url.scraper_enabled?

    artist_url.scraper.process!
  end
end
