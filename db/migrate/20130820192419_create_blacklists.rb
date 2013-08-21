class CreateBlacklists < ActiveRecord::Migration
  def change
    create_table :blacklists do |t|
      t.string :phone
      t.timestamps
    end

    add_index :blacklists, :phone, unique: true
  end
end
