# frozen_string_literal: true

class RemoveUnnecessaryBoolColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :submission_files, :hide_from_search
    remove_column :submission_files, :in_backlog
  end
end
