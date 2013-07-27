class AddIpToUserApps < ActiveRecord::Migration
  def change
    add_column :user_apps, :ip, :string
  end
end
