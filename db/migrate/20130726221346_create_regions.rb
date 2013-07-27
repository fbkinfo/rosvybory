class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.integer :kind
      t.references :parent, index: true
      t.string :name

      t.timestamps
    end
  end
end
