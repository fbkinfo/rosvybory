class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.references :user, index: true
      t.references :role, index: true

      t.timestamps
    end
    add_index :user_roles, [:user_id, :role_id], unique: true
  end
end
