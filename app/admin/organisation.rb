ActiveAdmin.register Organisation do
  menu :parent => I18n.t('active_admin.menu.dictionaries'), :if => proc{ can? :manage, Organisation }

  controller do
    def permitted_params
      params.permit!
    end
  end
end
