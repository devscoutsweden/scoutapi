class CreateReferences < ActiveRecord::Migration
  def change
    create_table :references do |t|
      t.string :uri
      t.integer :type

      t.timestamps
    end
    create_join_table :activity_version, :reference do |t|
      t.index :activity_version_id
      t.index :reference_id
      #t.index [:activity_version_id, :reference_id], :name => 'activity_version_reference_join_index'
    end
  end
end
