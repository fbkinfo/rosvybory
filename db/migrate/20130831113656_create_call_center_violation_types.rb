class CreateCallCenterViolationTypes < ActiveRecord::Migration
  def change
    create_table :call_center_violation_types do |t|
      t.string :name
      t.references :violation_category

      t.timestamps
    end
  end
end
