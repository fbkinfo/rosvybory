class CallCenter::Report < ActiveRecord::Base
  has_and_belongs_to_many :child_reports, class_name: "CallCenter::Report", foreign_key: "parent_report_id",
                                            join_table: "call_center_reports_relations", association_foreign_key: "child_report_id"
  has_and_belongs_to_many :parent_reports, class_name: "CallCenter::Report", foreign_key: "child_report_id",
                                            join_table: "call_center_reports_relations", association_foreign_key: "parent_report_id"

  belongs_to :reporter
  accepts_nested_attributes_for :reporter

  belongs_to :violation
  accepts_nested_attributes_for :violation

  has_one :phone_call
  accepts_nested_attributes_for :reporter
end
