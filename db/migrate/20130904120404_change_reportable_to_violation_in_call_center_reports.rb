class ChangeReportableToViolationInCallCenterReports < ActiveRecord::Migration
  def up
    change_table :call_center_reports do |t|
      t.remove :reportable_id
      t.remove :reportable_type
      t.integer :violation_id
    end
  end

  def down
    change_table :call_center_reports do |t|
      t.integer :reportable_id
      t.string :reportable_type
      t.remove :violation_id
    end
  end
end
