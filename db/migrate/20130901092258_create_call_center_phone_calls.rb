class CreateCallCenterPhoneCalls < ActiveRecord::Migration
  def change
    create_table :call_center_phone_calls do |t|
      t.string :status
      t.string :number
      t.references :call_center_operator
      t.timestamps
    end
  end
end
