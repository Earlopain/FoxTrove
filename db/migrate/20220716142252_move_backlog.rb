# frozen_string_literal: true

class MoveBacklog < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :in_backlog, :boolean, null: false, default: false
    add_column :submission_files, :added_to_backlog_at, :timestamp, null: true
    SubmissionFile.reset_column_information
    Backlog.find_each do |backlog|
      next if backlog.submission_file.nil?

      backlog.submission_file.in_backlog = true
      backlog.submission_file.added_to_backlog_at = backlog.created_at
      backlog.submission_file.save!
    end
  end
end
