# frozen_string_literal: true

module ArtistHelper
  def active_artist_urls_collection(artist)
    scraping_enabled = artist.artist_urls.select(&:scraper?)
    scraping_enabled.map { |artist_url| ["#{artist_url.url_identifier} (#{artist_url.site.display_name})", artist_url.id] }
  end

  def backlog_artist_urls_collection
    artist_url_ids = ArtistUrl.joins(submissions: :submission_files).where.not(submission_files: { added_to_backlog_at: nil }).group(:id).count.keys
    artist_urls = ArtistUrl.where(id: artist_url_ids).order(:artist_id)
    artist_urls.map { |artist_url| ["#{artist_url.url_identifier} (#{artist_url.site.display_name})", artist_url.id] }
  end
end
