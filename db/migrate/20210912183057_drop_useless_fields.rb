# frozen_string_literal: true

class DropUselessFields < ActiveRecord::Migration[6.1]
  def change
    remove_column :sites, :direct_url_format, :string
    remove_column :sites, :notes, :string
    remove_column :sites, :allows_hotlinking, :boolean
    remove_column :sites, :stores_original, :boolean
    remove_column :sites, :original_easily_accessible, :boolean
    remove_column :artist_submissions, :direct_url, :string
  end
end
