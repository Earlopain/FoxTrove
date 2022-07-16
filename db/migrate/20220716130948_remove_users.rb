class RemoveUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :moderation_logs, :creator_id
    remove_column :moderation_logs, :creator_inet
    remove_column :artists, :creator_id
    remove_column :artist_urls, :creator_id
    remove_column :artist_urls, :approver_id
    remove_column :backlogs, :user_id
    drop_table :users
  end
end
