class RenameArtistIdentifierOnSite < ActiveRecord::Migration[7.0]
  def change
    rename_column :artist_urls, :identifier_on_site, :url_identifier
  end
end
