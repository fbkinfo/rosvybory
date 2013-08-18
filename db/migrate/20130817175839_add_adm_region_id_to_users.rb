class AddAdmRegionIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :adm_region, index: true
  end
end
