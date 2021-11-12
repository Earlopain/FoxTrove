class RenameAccountsToUsers < ActiveRecord::Migration[6.1]
  def change
    rename_table :accounts, :users
    rename_column :users, :username, :name
    rename_enum :account_levels, :user_levels
    rename_enum :account_permissions, :user_permissions
  end
end
