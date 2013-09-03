ActiveAdmin.register CallCenter::Violation do
  menu parent: I18n.t('active_admin.menu.call_center')
  actions :all

  index do
    [:id, :status, :violation_type_id, :created_at].each do |col|
      column col
    end
    column :text do |violation|
      violation.report.text
    end
    default_actions
  end

end
