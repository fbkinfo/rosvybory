class MakeRegionsAwesomeNestedSet < ActiveRecord::Migration
  def up
    add_column :regions, :lft, :integer
    add_column :regions, :rgt, :integer
    Region.reset_column_information
    Region.rebuild!
  end

  def down
    remove_column :regions, :lft, :integer
    remove_column :regions, :rgt, :integer
  end
end
