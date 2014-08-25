class CreateRatings < ActiveRecord::Migration
  def change
    create_join_table :activities, :users, table_name: :ratings do |t|
      t.integer :rating
      t.text :source_uri

      t.timestamps
      t.index :activity_id
      t.index :user_id
    end
  end
end
