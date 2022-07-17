# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_enum :user_levels, %w[unactivated member admin]
    create_enum :user_permissions, %w[
      delete_artist
      request_manual_update
      allow_url_moderation
    ]

    create_table :users do |t|
      t.text :name, null: false, index: true
      t.text :email, null: false, index: true
      t.enum :level, enum_type: :user_levels, null: false, index: true, default: "unactivated"
      t.enum :permissions, enum_type: :user_permissions, null: false, array: true, default: "{}"
      t.text :password_digest, null: false
      t.datetime :last_logged_in_at, null: false
      t.inet :last_ip_addr, null: false
      t.timestamps
    end
  end
end
