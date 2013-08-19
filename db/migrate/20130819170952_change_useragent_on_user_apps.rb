class ChangeUseragentOnUserApps < ActiveRecord::Migration
  def up
    change_column :user_apps, :useragent, :text
  end

  def down
    change_column :user_apps, :useragent, :string
  end
end
