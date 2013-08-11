class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name, :slug, :short_name, null: false

      t.timestamps
    end
    add_index :roles, :slug, unique: true
    add_index :roles, :name, unique: true
    add_index :roles, :short_name, unique: true
  end
end
