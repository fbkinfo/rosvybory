class AddUserAppIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_app_id, :integer
  end
end
