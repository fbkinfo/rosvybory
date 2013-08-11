class AddPhoneVerifiedToUserApps < ActiveRecord::Migration
  def change
    add_column :user_apps, :phone_verified, :boolean, default: false, null: false
  end
end
