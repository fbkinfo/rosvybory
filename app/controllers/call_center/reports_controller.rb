class CallCenter::ReportsController < ApplicationController
  layout "call_center"

  before_filter :authenticate_operator, only: [:new, :create]

  def new
    phone_call = new_phone_call_from params
    dislocation = Dislocation.find_by phone: phone_call.number

    @report = CallCenter::Report.new\
      reporter: new_reporter_from(dislocation),
      phone_call: phone_call,
      violation: CallCenter::Violation.new

    @uic = @report.reporter.try(:uic)
  end

  def create
    params[:call_center_report].delete(:violation_attributes) if params[:call_center_report][:violation_attributes][:violation_type_id].blank? # prevent creating empty violation, in case, if :violation_attributes key is presented
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

  def new_phone_call_from(params)
    CallCenter::PhoneCall.create \
      operator: current_user,
      number: params[:clid],
      status: "started",
      all_params: params
  end

  def permitted_params
    params.require(:call_center_report).permit :text, :parent_report_ids, reporter_attributes: [:phone, :uic, :user_id, :role, :uic_id, :current_role_id, :last_name, :first_name, :patronymic], violation_attributes: [:violation_type_id]
  end

  def new_reporter_from(dislocation)
    CallCenter::Reporter.new.tap do |reporter|
      if dislocation
        reporter.dislocation = dislocation
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
    redirect_to new_user_session_path unless can? :create, CallCenter::Report
  end
end
