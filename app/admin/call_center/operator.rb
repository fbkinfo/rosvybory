ActiveAdmin.register CallCenter::Operator do
  menu parent: I18n.t('active_admin.menu.call_center')
  actions :all

  index do
    [:id, :first_name, :last_name, :comp_number, :created_at, :updated_at].each do |col|
      column col
    end
    default_actions
  end

end

