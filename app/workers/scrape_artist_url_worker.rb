class ScrapeArtistUrlWorker
  include Sidekiq::Worker

  sidekiq_options queue: :scraping, lock: :until_executed, lock_ttl: 1.hour, on_conflict: :log

  def perform(artist_url_id)
    logger.info "START #{artist_url_id}"
    sleep 10
    logger.info "DONE #{artist_url_id}"
  end
end
