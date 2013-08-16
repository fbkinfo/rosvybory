class CreateCurrentRoles < ActiveRecord::Migration
  def change
    create_table :current_roles do |t|
      t.string :name, :slug, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
