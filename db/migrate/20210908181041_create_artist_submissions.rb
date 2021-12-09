class CreateArtistSubmissions < ActiveRecord::Migration[6.1]
  def change
    create_enum :file_extensions, %w[png jpg gif webp]

    create_table :artist_submissions do |t|
      t.references :artist_url, foreign_key: true, null: false
      t.text :identifier_on_site, null: false
      t.text :title_on_site, null: true
      t.text :description_on_site, null: true
      t.datetime :created_at_on_site, null: false
      t.text :file_name, null: false
      t.enum :file_extension, enum_type: :file_extensions, null: false
      t.text :sha256, null: false, index: true
      t.text :direct_url, null: true
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :size, null: false
      t.timestamps
    end
  end
end
