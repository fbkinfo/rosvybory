ActiveAdmin.register CallCenter::Report do
  menu parent: I18n.t('active_admin.menu.call_center')
  actions :all

  index do
    column :id
    column :text
    column :url do |report|
      link_to(report.send(:url), report.url) unless report.url.empty?
    end
    column :reporter do |report|
      r = report.reporter
      [r.last_name, r.first_name, r.patronymic].join ' '
    end
    column :created_at
    column :updated_at
    default_actions
  end

end
