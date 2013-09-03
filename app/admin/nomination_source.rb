ActiveAdmin.register NominationSource do
  menu :parent => I18n.t('active_admin.menu.dictionaries'), :if => proc{ can? :crud, NominationSource }
  batch_action :destroy, false

  filter :name
  filter :variant, :as => :select
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :variant, as: :select, collection: NominationSource.variants_with_names
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit(:nomination_source => [:name, :variant])
    end
  end
end
