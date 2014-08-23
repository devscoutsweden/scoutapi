class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.integer :status

      t.timestamps
    end
    add_reference :activities, :user, index: true
  end
end
