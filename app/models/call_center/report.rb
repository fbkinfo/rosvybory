class CallCenter::Report < ActiveRecord::Base
  has_and_belongs_to_many :child_reports, class_name: "CallCenter::Report", foreign_key: "parent_report_id",
                                            join_table: "call_center_reports_relations", association_foreign_key: "child_report_id"
  has_and_belongs_to_many :parent_reports, class_name: "CallCenter::Report", foreign_key: "child_report_id",
                                            join_table: "call_center_reports_relations", association_foreign_key: "parent_report_id"

  belongs_to :reviewer, class_name: User, foreign_key: "reviewer_id"

  belongs_to :reporter
  accepts_nested_attributes_for :reporter

  belongs_to :violation
  accepts_nested_attributes_for :violation

  has_one :phone_call
  accepts_nested_attributes_for :reporter

  after_commit :broadcast_report, :on => :create
  after_commit :send_report_json, :on => :update


  private
    def broadcast_report
      LiveReportsNotifier.instance.broadcast(self)
    end

    def send_report_json
      Resque.enqueue PushViolationToKartanarusheniy, {report_id: self.id} if approved?
    end
end
