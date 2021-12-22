class MultipleFilesPerUrl < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_files do |t|
      t.references :artist_submission, null: false
      t.timestamps
    end
  end
end
