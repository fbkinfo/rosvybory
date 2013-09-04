class AddOperatorIdToCallCenterPhoneCalls < ActiveRecord::Migration
  def up
    add_column :call_center_phone_calls, :operator_id, :integer
  end

  def down
    remove_column :call_center_phone_calls, :operator_id
  end
end
