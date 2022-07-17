# frozen_string_literal: true

class AddUniqueIndicies < ActiveRecord::Migration[7.0]
  def change
    add_index :artists, "lower(name)", name: "index_artists_on_lower_name", unique: true
    add_index :users, "lower(name)", name: "index_users_on_lower_name", unique: true
    add_index :users, "lower(email)", name: "index_users_on_lower_email", unique: true
    execute "CREATE UNIQUE INDEX index_artist_submissions_on_artist_url_and_identifier ON artist_submissions (artist_url_id, lower(identifier_on_site));"
    execute "CREATE UNIQUE INDEX index_artist_urls_on_site_and_identifier ON artist_urls (site_id, lower(identifier_on_site));"
  end
end
