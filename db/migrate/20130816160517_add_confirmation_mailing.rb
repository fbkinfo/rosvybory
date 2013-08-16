class AddConfirmationMailing < ActiveRecord::Migration
  def change
  	add_column :user_apps, :confirmation_token, :string
  	add_column :user_apps, :confirmed_at, :datetime
  end
end
