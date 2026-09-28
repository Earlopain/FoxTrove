class AddIqdbTimestampToSubmissionFiles < ActiveRecord::Migration[8.1]
  def change
    add_column :submission_files, :last_iqdb_checked_at, :timestamp, default: "1970-01-01"

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE submission_files
          SET last_iqdb_checked_at = result.max_created_at
          FROM (
            SELECT submission_file_id, MAX(created_at) AS max_created_at
            FROM e6_posts
            GROUP BY submission_file_id
          ) result
          WHERE result.submission_file_id = submission_files.id;
        SQL
      end
    end

    change_column_default :submission_files, :last_iqdb_checked_at, from: "1970-01-01", to: nil
  end
end
