ActiveAdmin.register CallCenter::Report do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 1, if: proc{ can? :read,  CallCenter::Report }
  
  actions :index, :show, :edit, :update


  scope 'Сообщения' do |items|
    items.where(violation_id: nil)
  end
  scope 'Нарушения' do |items|
    items.where("violation_id IS NOT ?", nil)
  end

  index do
    column :approved do |report|
      render "control/call_center/reports/approved", {report: report}
    end
    column :violation do |report|
      link_to report.violation.try(:violation_type).try(:name), control_call_center_violation_type_path(report.violation) if report.violation.present?
    end
    column :uic do |report|
      link_to report.reporter.uic.name, control_uic_path(report.reporter.uic) if report.reporter.uic.present?
    end
    column :text
    column :reporter do |report|
      reporter = report.reporter
      if reporter.dislocation.present?
        link_to reporter.dislocation.full_name, control_dislocation_path(reporter.dislocation)
      else
        [reporter.last_name, reporter.first_name, reporter.patronymic].join " "
      end
    end
    column :phone do |report|
      report.reporter.phone
    end
    column :current_role do |report|
      report.reporter.current_role.try(:name)
    end
    column :created_at
    default_actions
  end

  controller do
    def permitted_params
      params.require(:call_center_report).permit :approved
    end

    def update
      @report = CallCenter::Report.find params[:id]
      @report.update permitted_params
      respond_to do |format|
        format.json {render json: @report, location: @report}
      end
    end
  end
end
