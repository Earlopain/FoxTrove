# frozen_string_literal: true

class AddIgnoreColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :hide_from_search, :boolean, null: false, default: false
    add_column :submission_files, :hidden_from_search_at, :timestamp, null: true
  end
end
