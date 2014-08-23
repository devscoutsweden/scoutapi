class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :group
      t.string :name
      t.integer :status

      t.timestamps
    end

    add_reference :categories, :user, index: true

    add_index :categories, [:group, :name], unique: true

    create_join_table :categories, :activity_versions do |t|
      t.index :category_id
      t.index :activity_version_id
      #t.index [:activity_version_id, :category_id], :name => 'comment_version_media_file_join_index1'
      #t.index [:media_file_id, :comment_version_id], :name => 'comment_version_media_file_join_index2'
    end
  end
end
