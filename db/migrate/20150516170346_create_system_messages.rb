class CreateSystemMessages < ActiveRecord::Migration
  def change
    create_table :system_messages do |t|
      t.string :key, limit: 100, null: false
      t.string :value, limit: 10000, null: false
      t.datetime :valid_to, null: true
      t.datetime :valid_from, null: true

      t.timestamps
    end
    add_reference :system_messages, :user, index: true
    add_index :system_messages, :key, unique: false
  end
end
