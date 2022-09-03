# frozen_string_literal: true

class AddPostDeletedColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :e6_iqdb_data, :post_is_deleted, :boolean, null: false, default: false
    change_column_default :e6_iqdb_data, :post_is_deleted, nil
  end
end
