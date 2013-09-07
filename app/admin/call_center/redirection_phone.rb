ActiveAdmin.register CallCenter::RedirectionPhone do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 8, if: proc{ can? :read,  CallCenter::RedirectionPhone }
  actions :all

  index do
    column :name
    column :number
  end

  controller do
    def permitted_params
      params.permit!
    end
  end

end
