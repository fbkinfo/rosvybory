class AddUniqueIndexOnNameToRegions < ActiveRecord::Migration
  def change
    add_index :regions, :name, unique: true
  end
end
