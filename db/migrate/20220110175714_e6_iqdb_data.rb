class E6IqdbData < ActiveRecord::Migration[7.0]
  def change
    create_table :e6_iqdb_data do |t|
      t.references :submission_file, null: false
      t.integer :post_id, null: false
      t.integer :post_width, null: false
      t.integer :post_height, null: false
      t.integer :post_size, null: false
      t.float :similarity_score, null: false
      t.boolean :is_exact_match, null: false
      t.timestamps
    end
  end
end
