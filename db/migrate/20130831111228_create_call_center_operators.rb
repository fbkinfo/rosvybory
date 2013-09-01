class CreateCallCenterOperators < ActiveRecord::Migration
  def change
    create_table :call_center_operators do |t|
      t.string :first_name
      t.string :last_name
      t.integer :comp_number

      t.timestamps
    end
  end
end
