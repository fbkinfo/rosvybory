ActiveAdmin.register MobileGroup do
  menu :if => proc{ can? :crud, MobileGroup }, :priority => 30

  filter :organisation, label: 'Организация', as: :select, collection: proc { Organisation.order(:name).accessible_by(current_ability, :contribute_to) }, :input_html => {:style => "width: 230px;"}
  filter :adm_region, :as => :select, :collection => proc { Region.adm_regions.accessible_by(current_ability) }, :input_html => {:style => "width: 230px;"}
  filter :region, :as => :select, :collection => proc { Region.mun_regions.accessible_by(current_ability) }, :input_html => {:style => "width: 230px;"}
  filter :name

  index do
    selectable_column
    column :organisation, &:organisation_name
    column :adm_region, &:adm_region_name
    column :region, &:region_name
    column :name
    actions
  end

  form do |f|
    f.inputs data: {role: 'user-fields-container'} do
      f.input :organisation, as: :select, collection: Organisation.accessible_by(current_ability, :contribute_to), input_html: {style: "width: 220px;"}
      f.input :adm_region, as: :select, collection: Region.adm_regions.pluck(:name, :id), input_html: {style: "width: 220px;", data: {role: 'adm-region-select', regions: regions_hash}}
      f.input :region, as: :select, collection: f.object.adm_region ? f.object.adm_region.regions.pluck(:name, :id) : [], input_html: {style: "width: 220px;", data: {role: 'region-select'}}
      f.input :name
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit(:mobile_group => [:adm_region_id, :organisation_id, :region_id, :name])
    end

    def new
      @mobile_group = MobileGroup.new(:organisation_id => current_user.organisation_id)
    end
  end

end
