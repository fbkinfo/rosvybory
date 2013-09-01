class CreateCallCenterReports < ActiveRecord::Migration
  def change
    create_table :call_center_reports do |t|
      t.text :text
      t.string :url
      t.references :reportable, polymorphic: true, index: true
      t.references :reporter

      t.timestamps
    end
  end
end
