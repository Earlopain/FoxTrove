# frozen_string_literal: true

class AddScraperStatus < ActiveRecord::Migration[7.0]
  def change
    add_column :artist_urls, :scraper_status, :jsonb, null: false, default: {}
  end
end
