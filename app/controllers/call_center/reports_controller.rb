class CallCenter::ReportsController < ApplicationController
  layout "call_center"

  before_filter :authenticate_operator, only: [:new, :create]

  def new
    @dislocation = Dislocation.find_by phone: params[:phone]
    @report = CallCenter::Report.new\
      reporter: new_reporter_from(@dislocation),
      phone_call: CallCenter::PhoneCall.create(number: params[:phone], status: "started"),
      violation: CallCenter::Violation.new

    @uic = @report.reporter.try(:uic)
  end

  def create
    report = CallCenter::Report.new permitted_params
    report.reporter.tap do |reporter|
      if reporter.dislocation.present?
        reporter.first_name = reporter.dislocation.first_name
        reporter.last_name = reporter.dislocation.last_name
        reporter.patronymic = reporter.dislocation.patronymic
        reporter.mobile_group = reporter.dislocation.mobile_group
        reporter.adm_region = reporter.dislocation.adm_region
      end
    end
    report.save

    CallCenter::PhoneCall.find(params[:phone_call_id]).tap do |phone_call|
      phone_call.report = report
      phone_call.status = "completed"
      phone_call.save
    end

    redirect_to new_call_center_report_path
  end

  private

  def permitted_params
    params.require(:call_center_report).permit :text, {violation_attributes: [:violation_type_id]}, :parent_report_ids, reporter_attributes: [:phone, :uic, :user_id, :role, :uic_id, :current_role_id, :last_name, :first_name, :patronymic]
  end

  def new_reporter_from(dislocation)
    CallCenter::Reporter.new.tap do |reporter|
      if dislocation
        reporter.uic        = dislocation.user_current_roles.first.try(:uic)
        reporter.phone      = dislocation.phone
        reporter.first_name = dislocation.first_name
        reporter.last_name  = dislocation.last_name
        reporter.patronymic = dislocation.patronymic
        reporter.current_role = dislocation.user_current_roles.first.try(:current_role)
        reporter.mobile_group = dislocation.mobile_group
        reporter.adm_region = dislocation.adm_region
      end
    end
  end

  def authenticate_operator
    redirect_to root_path, notice: I18n.t("views.call_center.reports.new.access_denied") unless can? :create, CallCenter::Report
  end
end
