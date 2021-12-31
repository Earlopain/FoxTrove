class AddSubmissionFileIdentifier < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :file_identifier, :text, null: false
    add_index :submission_files, %i[artist_submission_id file_identifier], unique: true, name: "index_submission_files_on_artist_submission_id_and_file_id"
  end
end
