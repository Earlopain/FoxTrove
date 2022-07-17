# frozen_string_literal: true

class AddBacklog < ActiveRecord::Migration[7.0]
  def change
    create_table :backlogs do |t|
      t.references :user, null: false
      t.references :submission_file, null: false
      t.index %i[user_id submission_file_id], unique: true
      t.timestamps
    end
  end
end
