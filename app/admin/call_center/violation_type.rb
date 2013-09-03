ActiveAdmin.register CallCenter::ViolationType do
  menu parent: I18n.t('active_admin.menu.call_center')
  actions :all

  index do
   [:id, :name].each do |col|
      column col
    end
    column :violation_category do |violation_type|
      violation_type.violation_category.name
    end
    default_actions
  end

end
