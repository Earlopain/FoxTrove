class LogEventsToScraperLogs < ActiveRecord::Migration[8.1]
  def change
    drop_table :log_events do |t|
      t.references :loggable, polymorphic: true, null: false, index: true
      t.jsonb :payload, null: false
      t.datetime :created_at, null: false
      t.integer :action, null: false
    end

    create_table :scraper_logs do |t|
      t.string :site_type, null: false
      t.string :api_identifier
      t.string :url_identifier
      t.jsonb :request, null: false
      t.datetime :created_at, null: false
      t.index %i[site_type api_identifier]
      t.index %i[site_type url_identifier]
    end
  end
end
