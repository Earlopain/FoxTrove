class AddTimezoneToTimestamps < ActiveRecord::Migration[7.0]
  def change
    add_timezone :active_storage_attachments, false, :created_at
    add_timezone :active_storage_blobs, false, :created_at
    add_timezone :ar_internal_metadata, true
    add_timezone :artist_submissions, true, :created_at_on_site
    add_timezone :artist_urls, true, :created_at_on_site, :last_scraped_at
    add_timezone :artists, true
    add_timezone :moderation_logs, false, :created_at
    add_timezone :submission_files, true
    add_timezone :users, true, :last_logged_in_at
    add_column :users, :time_zone, :text, null: false
  end

  def add_timezone(table, has_timestamps, *columns)
    if has_timestamps
      change_column table, :created_at, :datetime, precision: 6
      change_column table, :updated_at, :datetime, precision: 6
    end
    columns.each do |column|
      change_column table, column, :datetime, precision: 6
    end
  end
end
