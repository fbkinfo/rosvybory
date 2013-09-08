ActiveAdmin.register CallCenter::Report do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 1, if: proc{ can? :read,  CallCenter::Report }

  actions :index, :show, :edit, :update

  scope 'Сообщения' do |items|
    items.where(violation_id: nil)
  end
  scope 'Нарушения' do |items|
    items.where("violation_id IS NOT ?", nil)
  end
  scope 'Одобренные' do |items|
    items.where(approved: true)
  end
  scope 'Отклонённые' do |items|
    items.where(approved: false)
  end
  scope 'Проверить' do |items|
    items.where(approved: nil)
  end

  index :as => ActiveAdmin::Views::IndexAsCachedTable do
    column :approved, sortable: "approved" do |report|
      render "control/call_center/reports/approved", {report: report}
    end
    column :violation_type do |report|
      render "control/call_center/reports/violation_type", {report: report}
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
    column :created_at, :sortable => true
    default_actions
  end

  sidebar :live, :only => :index do
    text_node link_to("Включить автоматическое обновление сообщений", '#', :class => 'enable-live-reports-link', :data => {reload_url: fast_row_control_call_center_reports_path, :reload_params => {q: params[:q]}})
    div(:class => 'live-reports-status', :style => 'display: none') do
      text_node "Сообщения обновляются автоматически."
      text_node link_to("Выключить", '#', :class => 'off-live-reports-link')
    end
  end

  collection_action :fast_row do
    render :template => 'control/call_center/reports/fast_row', :layout => false
  end

  controller do
    def permitted_params
      params.require(:call_center_report).permit :approved, violation_attributes: [:violation_type_id]
    end

    def update
      @report = CallCenter::Report.includes(violation: :violation_type).find params[:id]
      @report.reviewer = current_user
      @report.update permitted_params
      respond_to do |format|
        format.json {render json: @report, location: @report, include: {violation: {include: :violation_type}}}
      end
    end
  end
end
