ActiveAdmin.register Blacklist do
  menu :parent => I18n.t('active_admin.menu.dictionaries'), :if => proc{ can? :manage, Blacklist }

  #actions :all, except: [:show, :edit]
  batch_action :destroy, false

  controller do
    def permitted_params
      params.permit!
    end
  end
end
