class MoveToE6Users < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :e6_user_id, :integer
    add_index :users, :e6_user_id, name: :index_e6_user_id, unique: true
    User.reset_column_information
    User.find_each.with_index do |user, index|
      user.e6_user_id = index
      user.save
    end
    change_column_null :users, :e6_user_id, false
    remove_column :users, :email
  end
end
