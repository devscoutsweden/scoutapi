class CreateMediaFiles < ActiveRecord::Migration
  def change
    create_table :media_files do |t|
      t.binary :data
      t.integer :status
      t.string :mime_type
      t.string :hash

      t.timestamps
    end
  end
end
