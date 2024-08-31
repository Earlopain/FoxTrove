class RenameE6PostsTable < ActiveRecord::Migration[7.0]
  def change
    rename_table :e6_iqdb_data, :e6_posts
  end
end
