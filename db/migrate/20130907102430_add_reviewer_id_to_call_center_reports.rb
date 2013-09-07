class AddReviewerIdToCallCenterReports < ActiveRecord::Migration
  def up
    add_column :call_center_reports, :reviewer_id, :integer
  end

  def down
    remove_column :reviewer_id
  end
end
