class CreateActivityVersions < ActiveRecord::Migration
  def change
    create_table :activity_versions do |t|
      t.integer :status
      t.string :name
      t.datetime :published_at
      t.string :descr_material
      t.string :descr_introduction
      t.string :descr_prepare
      t.string :descr_main
      t.string :descr_safety
      t.string :descr_notes
      t.integer :age_min
      t.integer :age_max
      t.integer :participants_min
      t.integer :participants_max
      t.integer :time_min
      t.integer :time_max
      t.boolean :featured

      t.timestamps
    end

    add_reference :activity_versions, :activity, index: true
    add_reference :activity_versions, :user, index: true

    create_join_table :activity_version, :media_file do |t|
      t.boolean :featured

      t.index :activity_version_id
      t.index :media_file_id
      #t.index [:activity_version_id, :media_file_id], :name => 'activity_version_media_file_join_index1'
      #t.index [:media_file_id, :activity_version_id], :name => 'activity_version_media_file_join_index2'
    end

  end
end
