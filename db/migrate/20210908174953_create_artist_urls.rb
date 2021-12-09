class CreateArtistUrls < ActiveRecord::Migration[6.1]
  def change
    create_table :artist_urls do |t|
      t.references :creator, foreign_key: { to_table: :users }, null: false
      t.references :approver, foreign_key: { to_table: :users }, null: true
      t.references :artist, foreign_key: true, null: false
      t.references :site, foreign_key: true, null: false
      t.text :identifier_on_site, null: false, index: true
      t.datetime :created_at_on_site, null: false
      t.text :about_on_site, null: false
      t.boolean :scraping_disabled, null: false, default: false
      t.datetime :last_scraped_at, null: true
      t.text :last_scraped_submission_identifier, null: true
      t.text :sidekiq_job_id, null: true
      t.timestamps
    end
  end
end
