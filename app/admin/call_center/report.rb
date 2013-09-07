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
  scope I18n.t("activerecord.attributes.call_center/report.needs_mobile_group") do |items|
    items.where needs_mobile_group: true
  end

  index do
    column :approved, sortable: "approved" do |report|
      render "control/call_center/reports/approved", {report: report}
    end
    column :violation_type do |report|
      render "control/call_center/reports/violation_type", {report: report}
    end
    column :uic do |report|
      link_to report.reporter.uic.name, control_uic_path(report.reporter.uic) if report.reporter.uic.present?
    end
    column :text do |report|
      html  = content_tag :div, report.text
      html += content_tag :p, I18n.t("activerecord.attributes.call_center/report.needs_mobile_group"), class: "needs-mobile-group" if report.needs_mobile_group
      raw html
    end
    column :reporter do |report|
      render "control/call_center/reports/reporter", {report: report}
    end
    column :created_at
    default_actions
  end

  sidebar :live, :only => :index do
    link_to "Включить автоматическое обновление сообщений", '#', :class => 'enable-live-reports-link', :data => {reload_url: request.path, :reload_params => {q: params[:q]}}
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
