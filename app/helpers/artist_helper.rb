module ArtistHelper
  def active_artist_urls_collection(artist)
    scraping_enabled = artist.artist_urls.reject { |url| url.site.class != Sites::ScraperDefinition }
    scraping_enabled.map { |artist_url| ["#{artist_url.identifier_on_site} (#{artist_url.site.display_name})", artist_url.id] }
  end
end
