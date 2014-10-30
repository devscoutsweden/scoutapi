class AddUriUniqueConstraintToMediaFiles < ActiveRecord::Migration
  def change
    add_index :media_files, [:uri], unique: true
  end
end
