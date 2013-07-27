class AddRegionIdToUserApps < ActiveRecord::Migration
  def change
    add_reference :user_apps, :region, index: true
  end
end
