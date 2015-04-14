class CreateActivityRelations < ActiveRecord::Migration
  def change
    create_table :activity_relations do |t|
      t.integer :activity_id, :null => false
      t.integer :related_activity_id, :null => false
      t.boolean :is_auto_generated, :null => false
      t.integer :owner_id, :null => false
    end
    add_index :activity_relations, [:activity_id, :related_activity_id], unique: true, name: :activity_relations_unique
    add_index :activity_relations, [:owner_id], unique: false, name: :activity_relations_owner_id
  end
end
