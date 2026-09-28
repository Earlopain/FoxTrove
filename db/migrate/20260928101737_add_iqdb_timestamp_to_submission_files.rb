class AddIqdbTimestampToSubmissionFiles < ActiveRecord::Migration[8.1]
  def change
    add_column :submission_files, :last_iqdb_checked_at, :timestamp
  end
end
