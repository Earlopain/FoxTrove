# frozen_string_literal: true

class AddContentType < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :content_type, :text
  end
end
