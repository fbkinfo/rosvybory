class CreateUserAppCurrentRoles < ActiveRecord::Migration
  def change
    create_table :user_app_current_roles do |t|
      t.references :user_app, null: false
      t.references :current_role, index: true, null: false
      t.string :value

      t.timestamps
    end
    add_index :user_app_current_roles, [:user_app_id, :current_role_id], unique: true
  end
end
