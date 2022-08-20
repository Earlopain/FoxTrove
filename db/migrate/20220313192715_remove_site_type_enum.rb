# frozen_string_literal: true

class RemoveSiteTypeEnum < ActiveRecord::Migration[7.0]
  def change
    rename_column :artist_urls, :site_type, :site_type_enum
    add_column :artist_urls, :site_type, :integer

    change_column_null :artist_urls, :site_type, false
    remove_column :artist_urls, :site_type_enum
    execute "DROP TYPE artist_url_sites;"
    add_index :artist_urls, %i[site_type api_identifier], name: :index_site_type_on_api_identifier, unique: true
    execute "CREATE UNIQUE INDEX index_artist_urls_on_site_and_url_identifier ON artist_urls (site_type, lower(url_identifier));"
  end
end
