class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_enum :account_levels, %w[unactivated member admin]
    create_enum :account_permissions, %w[
      delete_artist
      request_manual_update
      allow_url_moderation
    ]

    create_table :accounts do |t|
      t.text :username, null: false, index: true
      t.text :email, null: false, index: true
      t.enum :level, enum_name: :account_levels, null: false, index: true, default: "unactivated"
      t.enum :permissions, enum_name: :account_permissions, null: false, array: true, default: "{}"
      t.text :password_digest, null: false
      t.datetime :last_logged_in_at, null: false
      t.inet :last_ip_addr, null: false
      t.timestamps
    end
  end
end
