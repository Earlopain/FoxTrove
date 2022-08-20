# frozen_string_literal: true

class MoveBacklog < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :in_backlog, :boolean, null: false, default: false
    add_column :submission_files, :added_to_backlog_at, :timestamp, null: true
  end
end
