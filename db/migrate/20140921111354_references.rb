class References < ActiveRecord::Migration
  def up
    remove_column :references, :type
    add_column :references, :description, :string
  end

  def down
    remove_column :references, :description
    add_column :references, :type, :integer
  end
end
