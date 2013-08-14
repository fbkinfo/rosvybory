class AddForwardedForToUserApps < ActiveRecord::Migration
  def change
    add_column :user_apps, :forwarded_for, :string
  end
end
