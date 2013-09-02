class CallCenter::ReportsController < ApplicationController
  layout "call_center"

  def new
    @dislocation = Dislocation.find_by phone: params[:phone]
    @report = CallCenter::Report.new
    @report.reporter = new_reporter_from(@dislocation)
    
    @uic = (@dislocation && @dislocation.current_roles.present?) ? Uic.find_by(number: @dislocation.current_roles.first.uic) : nil
  end

  def create
    @report = CallCenter::Report.create(report_params)
  end

  def update
  end


  private

  def report_params
    params.require(:call_center_report).permit(reporter_attributes: [:phone, :dislocation, :uic, :role, { report: [:text, violation: [:violation_type] ] }, :parent_report_ids ])
  end

  def new_reporter_from(dislocation)
    CallCenter::Reporter.new.tap do |reporter|
      if dislocation
        reporter.uic        = dislocation.current_roles.first.try(:num),
        reporter.phone      = dislocation.phone,
        reporter.first_name = dislocation.first_name,
        reporter.last_name  = dislocation.last_name,
        reporter.patronymic = dislocation.patronymic
      end
    end
  end
end
