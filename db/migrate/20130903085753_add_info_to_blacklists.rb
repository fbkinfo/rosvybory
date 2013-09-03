class AddInfoToBlacklists < ActiveRecord::Migration
  def change
    add_column :blacklists, :info, :text
  end
end
