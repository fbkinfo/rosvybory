class AddHasVideoToUserApps < ActiveRecord::Migration
  def change
    add_column :user_apps, :has_video, :boolean
  end
end
