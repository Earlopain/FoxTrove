class CreateModerationLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :moderation_logs do |t|
      t.references :creator, foreign_key: { to_table: :accounts }, null: false
      t.inet :creator_inet, null: false, index: true
      t.text :model_type, null: false, index: true
      t.integer :model_id, null: false, index: true
      t.text :action, null: false, index: true
      t.jsonb :payload, null: false
      t.datetime :created_at, null: false
    end
  end
end
