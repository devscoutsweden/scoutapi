class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :status

      t.timestamps
    end
    add_reference :comments, :user, index: true
    add_reference :comments, :activity, index: true
  end
end
