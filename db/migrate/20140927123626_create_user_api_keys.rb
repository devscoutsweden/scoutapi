class CreateUserApiKeys < ActiveRecord::Migration
  def change
    create_table :user_api_keys do |t|
      t.string :key

      t.timestamps
    end
    add_reference :user_api_keys, :user, index: true
    add_index :user_api_keys, :key, unique: true
  end
end
