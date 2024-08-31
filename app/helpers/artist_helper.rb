module ArtistHelper
  def active_artist_urls_collection(artist)
    scraping_enabled = artist.artist_urls.select(&:scraper?)
    scraping_enabled.map { |artist_url| ["#{artist_url.unescaped_url_identifier} (#{artist_url.site.display_name})", artist_url.id] }
  end

  def backlog_artist_urls_collection
    artist_url_collection(ArtistUrl.search(in_backlog: true))
  end

  def hidden_artist_urls_collection
    artist_url_collection(ArtistUrl.search(hidden_from_search: true))
  end

  def oldest_last_scraped_at_text(artist)
    return "Never" unless artist.oldest_last_scraped_at

    time_ago artist.oldest_last_scraped_at
  end

  private

  def artist_url_collection(artist_url_collection)
    artist_urls = ArtistUrl.where(id: artist_url_collection.group(:id).count.keys).order(:artist_id)
    artist_urls.map { |artist_url| ["#{artist_url.unescaped_url_identifier} (#{artist_url.site.display_name})", artist_url.id] }
  end
end
