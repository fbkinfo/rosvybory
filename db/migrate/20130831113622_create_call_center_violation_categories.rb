class CreateCallCenterViolationCategories < ActiveRecord::Migration
  def change
    create_table :call_center_violation_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
