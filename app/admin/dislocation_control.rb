ActiveAdmin.register DislocationControl do
  decorate_with DislocationControlDecorator

  actions :index
  menu :if => proc{ can? :view_dislocation, User }, :priority => 20
  batch_action :destroy, false

  config.sort_order = 'kind_asc'

  index :download_links => false do
    column :number, :sortable => :name, &:number_and_region
    column :participants_count
    7.times do |i|
      column :"participant_#{i}" do |uic|
        uic.human_participant i, (can? :view_user_contacts, uic.participant(i).try(:user))
      end
    end
    column :others do |uic|
      if uic.participants_count > 7
        link_to 'Остальные', control_dislocations_path('q' => {'current_role_uic_equals' => uic.number}), :target => '_blank'
      end
    end
  end

  filter :kind, :as => :select, :collection => proc { Uic.kind.values.map {|k| [Uic.human_kind(k), Uic.send("#{k}_value")]} }
  filter :number
  filter :region_adm_region_id, as: :select, collection: Region.adm_regions
  filter :region, as: :select, collection: Region.mun_regions
  filter :participants_count, as: :numeric_range, :label => 'Количество наблюдателей'

  controller do

    def apply_sorting(chain)
      op = params[:order]
      if op == 'name_desc' || op == 'name_asc'
        chain = chain.joins(:region).reorder("regions.name, uics.name")
        op.ends_with?('_asc')? chain.reverse_order : chain  # hack: invert asc/desc. active admin adds _desc by default, which is not convenient
      else
        super
      end
    end

    def scoped_collection
      DislocationControl.includes(:user_current_roles)
    end
  end
end
