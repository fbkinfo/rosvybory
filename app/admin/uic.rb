ActiveAdmin.register Uic do
  menu :parent => I18n.t('active_admin.menu.dictionaries'), :if => proc{ can? :crud, NominationSource }

  actions :all, :except => [:new]
  batch_action :destroy, false

  filter :kind, :as => :select, :input_html => {:style => "width: 230px;"}
  filter :adm_region_id, :as => :select, :collection => proc { Region.adm_regions }, :input_html => {:style => "width: 230px;"}
  filter :region_id, :as => :select, :collection => proc { Region.mun_regions }, :input_html => {:style => "width: 230px;"}
  filter :name
  filter :number, :as => :numeric

  index do
    column :adm_region, &:adm_region_name
    column :region, -> (uic) { uic.region_name unless uic.region.try(:adm_region?) }
    column :name
    column :number
    column :is_temporary, -> (uic) { I18n.t(uic.is_temporary.to_s) }
    column :has_koib, -> (uic) { I18n.t(uic.has_koib.to_s) }
  end

  # form do |f|
  #   f.inputs do
  #     f.input :name
  #   end
  #   f.actions
  # end

  controller do
    def permitted_params
      params.permit(:nomination_source => [:name, :variant])
    end
  end
end
