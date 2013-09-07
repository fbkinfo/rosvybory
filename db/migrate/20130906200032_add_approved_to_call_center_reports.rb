class AddApprovedToCallCenterReports < ActiveRecord::Migration
  def up
    add_column :call_center_reports, :approved, :boolean
  end

  def down
    remove_column :call_center_reports, :approved
  end
end
