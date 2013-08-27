class ChangeUsersOptionalEmail < ActiveRecord::Migration
  def change
    remove_index :users, :email
    change_column :users, :email, :string, :null => true, :default => nil
  end
end
