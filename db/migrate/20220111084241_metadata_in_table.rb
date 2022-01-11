class MetadataInTable < ActiveRecord::Migration[7.0]
  def change
    change_table :submission_files, bulk: true do |t|
      t.integer :width
      t.integer :height
      t.integer :size
    end
  end
end
