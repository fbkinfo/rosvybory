class RenameOperatorIdToReportIdInCallCenterPhoneCalls < ActiveRecord::Migration
  def up
    change_table :call_center_phone_calls do |t|
      t.rename :call_center_operator_id, :report_id
    end
  end

  def down
    change_table :call_center_phone_calls do |t|
      t.rename :report_id, :call_center_operator_id
    end
  end
end
