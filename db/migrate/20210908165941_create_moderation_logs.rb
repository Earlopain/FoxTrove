class CreateModerationLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :moderation_logs do |t|
      t.references :creator, foreign_key: { to_table: :accounts }, null: false
      t.inet :creator_inet, null: false, index: true
      t.text :loggable_type, null: false, index: true
      t.integer :loggable_id, null: false, index: true
      t.text :action, null: false, index: true
      t.jsonb :payload, null: false
      t.datetime :created_at, null: false
    end

    add_index :moderation_logs, %i[loggable_type loggable_id]
  end
end
