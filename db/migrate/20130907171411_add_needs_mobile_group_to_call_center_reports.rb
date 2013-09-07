class AddNeedsMobileGroupToCallCenterReports < ActiveRecord::Migration
  def up
    add_column :call_center_reports, :needs_mobile_group, :boolean
  end

  def down
    remove_column :call_center_reports, :needs_mobile_group
  end
end
