ActiveAdmin.register DislocationControl do
  decorate_with DislocationControlDecorator

  actions :index
  menu :if => proc{ can? :view_dislocation, User }, :priority => 20

  config.sort_order = 'kind_asc'

  index do
    column :number, -> (uic) { uic.number_and_region }
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

  filter :kind, :as => :select, :collection => [['ТИК', 1], ['УИК', 2]]
  filter :number
  filter :region_parent_id, as: :select, collection: Region.adm_regions,  :input_html => {:style => "width: 220px;"}
  filter :region, as: :select, collection: Region.mun_regions,  :input_html => {:style => "width: 220px;"}

  controller do
    def scoped_collection
      DislocationControl.includes(:user_current_roles)
    end
  end
end
