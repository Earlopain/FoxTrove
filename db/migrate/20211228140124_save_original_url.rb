class SaveOriginalUrl < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :direct_url, :text, null: false
  end
end
