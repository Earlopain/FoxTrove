class RemoveBacklogTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :backlogs
  end
end
