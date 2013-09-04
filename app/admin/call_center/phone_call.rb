ActiveAdmin.register CallCenter::PhoneCall do
  menu parent: I18n.t('active_admin.menu.call_center')
  actions :all

  index do
    [:id, :status, :number, :report, :created_at, :updated_at].each do |col|
      column col
    end
    default_actions
  end

end
