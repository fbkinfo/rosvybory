class CreateUics < ActiveRecord::Migration
  def change
    create_table :uics do |t|
      t.references :region, index: true, null: false
      t.integer :number, null: false
      t.boolean :is_temporary, null: false, default: false
      t.string :has_koib, null: false, default: false

      t.timestamps
    end
  end
end
