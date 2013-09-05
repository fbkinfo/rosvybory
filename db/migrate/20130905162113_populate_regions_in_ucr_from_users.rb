class PopulateRegionsInUcrFromUsers < ActiveRecord::Migration
  def up
    UserCurrentRole.where(:region_id => nil).find_each do |ucr|
      if user = ucr.user
        ucr.update_column :region_id, user.region_id || user.adm_region_id
      end
    end
  end

  def down
    # sorry, no way back
  end
end
