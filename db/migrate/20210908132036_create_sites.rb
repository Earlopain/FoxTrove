class CreateSites < ActiveRecord::Migration[6.1]
  def change
    create_table :sites do |t|
      t.text :internal_name, null: false, index: true
      t.text :display_name, null: false
      t.text :homepage, null: false
      t.text :artist_url_format, null: false
      t.text :artist_identifier_regex, null: false
      t.text :artist_submission_format, null: false
      t.text :direct_url_format, null: false
      t.boolean :allows_hotlinking, null: false
      t.boolean :stores_original, null: false
      t.boolean :original_easily_accessible, null: false
      t.text :notes, null: false
      t.timestamps
    end
  end
end
