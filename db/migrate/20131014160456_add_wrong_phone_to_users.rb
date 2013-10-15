class AddWrongPhoneToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :wrong_phone, :boolean, null: false, default: false
  end
end
