class AddAdmRegionToUserApp < ActiveRecord::Migration
  def change
    add_column :user_apps, :adm_region_id, :integer
    add_index  :user_apps, [:adm_region_id]

    #UserApp.reset_column_information
    #UserApp.update_all 'adm_region_id = (SELECT parent_id FROM regions WHERE regions.id = user_apps.region_id)'
  end
end
