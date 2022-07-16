class DdMissingReferences < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :e6_iqdb_data, :submission_files
    add_foreign_key :submission_files, :artist_submissions
  end
end
