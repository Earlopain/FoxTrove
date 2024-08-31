class AddArtistUrlScraperStopMarker < ActiveRecord::Migration[7.1]
  def change
    add_column :artist_urls, :scraper_stop_marker, :datetime
    reversible do |dir|
      dir.up do
        execute("update artist_urls set scraper_stop_marker = last_scraped_at")
      end
    end
  end
end
