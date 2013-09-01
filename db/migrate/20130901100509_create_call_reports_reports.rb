class CreateCallReportsReports < ActiveRecord::Migration
  def change
    create_table :reports_reports do |t|
      t.references :parent_report, index: true
      t.references :child_report, index: true
      t.timestamps
    end
  end
end
