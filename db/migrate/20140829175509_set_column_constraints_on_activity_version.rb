class ActivityVersion < ActiveRecord::Migration
  def up
    change_column :activity_versions, :name, :string, :limit => 100
    change_column :activity_versions, :descr_material, :string, :limit => 10000
    change_column :activity_versions, :descr_introduction, :string, :limit => 10000
    change_column :activity_versions, :descr_prepare, :string, :limit => 10000
    change_column :activity_versions, :descr_main, :string, :limit => 10000
    change_column :activity_versions, :descr_safety, :string, :limit => 10000
    change_column :activity_versions, :descr_notes, :string, :limit => 10000
  end
  def down
    change_column :activity_versions, :name, :string, :limit => 255
    change_column :activity_versions, :descr_material, :string, :limit => 255
    change_column :activity_versions, :descr_introduction, :string, :limit => 255
    change_column :activity_versions, :descr_prepare, :string, :limit => 255
    change_column :activity_versions, :descr_main, :string, :limit => 255
    change_column :activity_versions, :descr_safety, :string, :limit => 255
    change_column :activity_versions, :descr_notes, :string, :limit => 255
    end
end
