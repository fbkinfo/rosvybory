class AddHasTicToRegion < ActiveRecord::Migration
  def change
    add_column :regions, :has_tic, :boolean, :default => false

    Region.reset_column_information

    unless Region.count.zero?
      adm_regions_with_single_tic = []
      adm_regions_with_single_tic << Region.where("name LIKE ?", "%Новомосковский%").first.id
      adm_regions_with_single_tic << Region.where("name LIKE ?", "%Троицкий%").first.id

      Region.mun_regions.where("parent_id NOT IN (?)", adm_regions_with_single_tic).update_all 'has_tic = TRUE'
      Region.adm_regions.where("id IN (?)", adm_regions_with_single_tic).update_all 'has_tic = TRUE'
    end
  end
end
