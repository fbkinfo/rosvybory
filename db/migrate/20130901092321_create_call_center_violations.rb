class CreateCallCenterViolations < ActiveRecord::Migration
  def change
    create_table :call_center_violations do |t|
      t.references :violation_type # cant name it just 'type'
      t.timestamps
    end
  end
end
