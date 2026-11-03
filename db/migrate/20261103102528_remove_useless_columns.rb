class RemoveUselessColumns < ActiveRecord::Migration[8.1]
  def change
    change_table(:artist_urls, bulk: true) do |t|
      t.remove :created_at_on_site, type: :datetime
      t.remove :about_on_site, type: :text
      t.remove :scraping_disabled, type: :boolean, null: false, default: false
    end
  end
end
