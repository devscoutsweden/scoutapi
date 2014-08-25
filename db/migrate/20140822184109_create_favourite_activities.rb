class CreateFavouriteActivities < ActiveRecord::Migration
  def change
    create_join_table :users, :activities, table_name: :favourite_activities do |t|
      t.timestamps

      t.index :user_id
      t.index :activity_id
    end
  end
end
