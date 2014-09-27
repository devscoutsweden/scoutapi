class MediafilesUri < ActiveRecord::Migration
  def up
  	remove_column :media_files, :hash
    add_column :media_files, :uri, :string
  end

  def down
  	remove_column :media_files, :uri
    add_column :media_files, :hash, :string
  end
end
