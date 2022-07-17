# frozen_string_literal: true

class AddUrlApiIdentifier < ActiveRecord::Migration[7.0]
  def change
    add_column :artist_urls, :api_identifier, :text
    add_index :artist_urls, %i[site_type api_identifier], name: :index_site_type_on_api_identifier, unique: true
  end
end
