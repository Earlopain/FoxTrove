# frozen_string_literal: true

class AddCorruptColumn < ActiveRecord::Migration[7.1]
  def change
    add_column :submission_files, :file_error, :string
  end
end
