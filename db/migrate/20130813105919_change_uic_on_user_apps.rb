class ChangeUicOnUserApps < ActiveRecord::Migration
  def change
    change_column :user_apps, :uic, :string
  end
end
