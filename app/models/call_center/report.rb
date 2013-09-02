class CallCenter::Report < ActiveRecord::Base
  has_and_belongs_to_many :child_reports, class_name: "CallCenter::Report", foreign_key: "parent_report_id",
                                            join_table: "reports_reports", association_foreign_key: "child_report_id"
  has_and_belongs_to_many :parent_reports, class_name: "CallCenter::Report", foreign_key: "child_report_id",
                                            join_table: "reports_reports", association_foreign_key: "parent_report_id"

  belongs_to :reporter
  accepts_nested_attributes_for :reporter
end
