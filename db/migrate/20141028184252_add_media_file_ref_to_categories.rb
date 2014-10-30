class AddMediaFileRefToCategories < ActiveRecord::Migration
  def change
    add_reference :categories, :media_file, index: true
  end
end
