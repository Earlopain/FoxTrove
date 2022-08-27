# frozen_string_literal: true

class LogEventsChangeActionType < ActiveRecord::Migration[7.0]
  def change
    remove_column :log_events, :action
    add_column :log_events, :action, :integer, null: false
  end
end
