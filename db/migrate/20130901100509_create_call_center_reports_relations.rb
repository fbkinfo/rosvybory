class CreateCallCenterReportsRelations < ActiveRecord::Migration
  def change
    create_table :call_center_reports_relations do |t|
      t.references :parent_report, index: true
      t.references :child_report, index: true
      t.timestamps
    end
  end
end
