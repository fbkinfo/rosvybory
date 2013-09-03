class CallCenter::ReportsController < ApplicationController
  layout "call_center"

  def new
    @dislocation = Dislocation.find_by phone: params[:phone]
    @report = CallCenter::Report.new reporter: new_reporter_from(@dislocation)
    @uic = @report.reporter.try(:uic)
  end

  def create
    report = CallCenter::Report.new permitted_params
    report.reporter.tap do |reporter|
      if reporter.dislocation.present?
        reporter.first_name = reporter.dislocation.first_name
        reporter.last_name = reporter.dislocation.last_name
        reporter.patronymic = reporter.dislocation.patronymic
      end
    end
    report.save
    
    redirect_to new_call_center_report_path
  end

  private

  def permitted_params
    params.require(:call_center_report).permit :parent_report_ids, reporter_attributes: [:phone, :uic, :user_id, :role, :uic_id, :current_role_id, :last_name, :first_name, :patronymic, {report: [:text, violation: [:violation_type]]}]
  end

  def new_reporter_from(dislocation)
    CallCenter::Reporter.new.tap do |reporter|
      if dislocation
        reporter.uic        = dislocation.user_current_roles.first.try(:uic)
        reporter.phone      = dislocation.phone
        reporter.first_name = dislocation.first_name
        reporter.last_name  = dislocation.last_name
        reporter.patronymic = dislocation.patronymic
        reporter.current_role = dislocation.user_current_roles.first.current_role
      end
    end
  end
end
