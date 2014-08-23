class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.boolean :email_verified
      t.string :display_name

      t.timestamps
    end
    add_index :users, [:email], unique: true
  end
end
