class CreateUserCurrentRoles < ActiveRecord::Migration
  def change
    create_table :user_current_roles do |t|
      t.belongs_to :user, index: true, null: false
      t.belongs_to :current_role, index: true, null: false
      t.belongs_to :uic, index: true, null: false
      t.belongs_to :region, index: true, null: false

      t.timestamps
    end
  end
end
