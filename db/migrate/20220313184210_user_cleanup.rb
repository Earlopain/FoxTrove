# frozen_string_literal: true

class UserCleanup < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :permissions
    execute "DROP TYPE user_permissions;"

    rename_column :users, :level, :level_enum
    add_column :users, :level, :integer

    change_column_null :users, :level, false
    remove_column :users, :level_enum
    execute "DROP TYPE user_levels;"
  end
end
