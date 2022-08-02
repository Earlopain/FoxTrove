# frozen_string_literal: true

class PostJsonNonNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :e6_iqdb_data, :post_json, false
  end
end
