class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities do |t|
      t.string :type
      t.string :data

      t.timestamps
    end
    add_reference :user_identities, :user, index: true
  end
end
