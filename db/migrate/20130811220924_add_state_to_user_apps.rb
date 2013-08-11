class AddStateToUserApps < ActiveRecord::Migration
  def change
    add_column :user_apps, :state, :string, default: "pending", null: false
  end
end
