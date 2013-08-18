class ChangeSocialAccountsOnUserApps < ActiveRecord::Migration
  def up
    change_column :user_apps, :social_accounts, :text
  end

  def down
    change_column :user_apps, :social_accounts, :string
  end
end
