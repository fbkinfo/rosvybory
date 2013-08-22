class AddMobileGroupIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_group_id, :integer
    add_index :users, :mobile_group_id
  end
end
