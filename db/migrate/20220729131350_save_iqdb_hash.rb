# frozen_string_literal: true

class SaveIqdbHash < ActiveRecord::Migration[7.0]
  def change
    add_column :submission_files, :iqdb_hash, :bytea
  end
end
