class RenameCurrentStatusToCurrentStatusesOnUserApps < ActiveRecord::Migration
  def change
    rename_column :user_apps, :current_status, :current_statuses
  end
end
