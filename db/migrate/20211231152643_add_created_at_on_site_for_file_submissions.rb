class AddCreatedAtOnSiteForFileSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :created_at_on_site, :datetime, null: false
  end
end
