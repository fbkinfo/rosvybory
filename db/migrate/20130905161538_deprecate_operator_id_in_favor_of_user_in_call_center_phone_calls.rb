class DeprecateOperatorIdInFavorOfUserInCallCenterPhoneCalls < ActiveRecord::Migration
  def up
    drop_table :call_center_operators
    rename_column :call_center_phone_calls, :operator_id, :user_id
  end

  def down
    create_table :call_center_operators do |t|
      t.string   :first_name
      t.string   :last_name
      t.string   :patronymic
      t.integer  :comp_number

      t.timestamps
    end
    rename_column :call_center_phone_calls, :user_id, :operator_id
  end
end
