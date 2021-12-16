class RemoveSubmissionFields < ActiveRecord::Migration[7.0]
  def change
    change_table :artist_submissions, bulk: true do |t|
      t.remove :file_name
      t.remove :file_extension
      t.remove :width
      t.remove :height
      t.remove :size
      t.remove :sha256
    end

    execute "DROP TYPE file_extensions;"
  end
end
