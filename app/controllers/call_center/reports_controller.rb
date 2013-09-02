class CallCenter::ReportsController < ApplicationController
  layout "call_center"

  def new
    @dislocation = Dislocation.find_by phone: params[:phone]
    @report = CallCenter::Report.new reporter: new_reporter_from(@dislocation)
    @uic = @report.reporter.try(:uic)
  end

  def create
    @report = CallCenter::Report.create(report_params)
  end

  private

  def report_params
    params.require(:call_center_report).permit(reporter_attributes: [:phone, :dislocation, :uic, :role, { report: [:text, violation: [:violation_type] ] }, :parent_report_ids ])
  end

  def new_reporter_from(dislocation)
    CallCenter::Reporter.new.tap do |reporter|
      if dislocation
        reporter.uic        = dislocation.user_current_roles.first.try(:uic)
        reporter.phone      = dislocation.phone
        reporter.first_name = dislocation.first_name
        reporter.last_name  = dislocation.last_name
        reporter.patronymic = dislocation.patronymic
        reporter.user_current_role = dislocation.user_current_roles.first
      end
    end
  end
end
