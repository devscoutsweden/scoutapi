class CreateCommentVersions < ActiveRecord::Migration
  def change
    create_table :comment_versions do |t|
      t.integer :status
      t.string :text
      t.string :source_uri

      t.timestamps
    end

    add_reference :comment_versions, :comment, index: true

    create_join_table :comment_version, :media_file do |t|
      t.index :comment_version_id
      t.index :media_file_id
      #t.index [:comment_version_id, :media_file_id], :name => 'comment_version_media_file_join_index1'
      #t.index [:media_file_id, :comment_version_id], :name => 'comment_version_media_file_join_index2'
    end
  end
end
