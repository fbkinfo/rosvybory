ActiveAdmin.register CallCenter::Report do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 1
  actions :index, :show

  scope 'Сообщения' do |items|
    items.where(violation_id: nil)
  end
  scope 'Нарушения' do |items|
    items.where("violation_id IS NOT ?", nil)
  end

  index do
    column :id do |report|
      link_to report.id, control_call_center_report_path(report)
    end
    column :violation do |report|
      link_to report.violation.violation_type.name, control_call_center_violation_type_path(report.violation) if report.violation.present?
    end
    column :uic do |report|
      link_to report.reporter.uic.name, control_uic_path(report.reporter.uic) if report.reporter.uic.present?
    end
    column :text
    column :url do |report|
      report.url.blank? ? "" : link_to(report.url[0..50]+"…", report.url)
    end
    column :reporter do |report|
      reporter = report.reporter
      if reporter.dislocation.present?
        link_to reporter.dislocation.full_name, control_dislocation_path(reporter.dislocation)
      else
        [reporter.last_name, reporter.first_name, reporter.patronymic].join " "
      end
    end
    column :current_role do |report|
      report.reporter.current_role.try(:name)
    end
    column :created_at
    default_actions
  end
end
