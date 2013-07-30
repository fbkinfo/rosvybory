class AddUserAgentToUserApp < ActiveRecord::Migration
  def change
    add_column :user_apps, :useragent, :string
  end
end
