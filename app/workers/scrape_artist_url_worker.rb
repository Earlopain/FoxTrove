class ScrapeArtistUrlWorker
  include Sidekiq::Worker

  sidekiq_options queue: :scraping, lock: :until_executed, lock_ttl: 1.hour, on_conflict: :log

  def perform(artist_url_id)
    artist_url = ArtistUrl.find_by id: artist_url_id
    return unless artist_url
    return unless artist_url.site.class == Sites::ScraperDefinition

    scraper = artist_url.scraper
    return unless scraper.enabled?

    scraper.init
    while scraper.more?
      scraper.fetch_next_batch.each do |api_submission|
        scraper.to_submission(api_submission).save artist_url
      end
    end
    artist_url.last_scraped_at = Time.current
    artist_url.save
  end
end
