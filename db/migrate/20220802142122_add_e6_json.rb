# frozen_string_literal: true

class AddE6Json < ActiveRecord::Migration[7.0]
  def change
    add_column :e6_iqdb_data, :post_json, :jsonb
  end
end
