class AddAdmRegionIdToRegions < ActiveRecord::Migration
  def up
    add_column :regions, :adm_region_id, :integer, :index => true
    Region.reset_column_information
    Region.find_each do |region|
      region.update_column :adm_region_id, region.adm_region?? region : region.parent.try(:adm_region)
    end
  end

  def down
    remove_column :regions, :adm_region_id
  end
end
