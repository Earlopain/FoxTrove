class RenameLogTable < ActiveRecord::Migration[7.0]
  def change
    rename_table :moderation_logs, :log_events
  end
end
