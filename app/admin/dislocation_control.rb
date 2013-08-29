ActiveAdmin.register DislocationControl do
  decorate_with DislocationControlDecorator

  actions :index
  menu :if => proc{ can? :view_dislocation, User }, :priority => 20

  config.sort_order = 'kind_asc'

  index do
    column :number, -> (uic) { uic.number_and_region }
    7.times do |i|
      column :"participant_#{i}", -> (uic) { uic.human_participant(i) }
    end
    column :others do |uic|
      if uic.participants_count > 7
        link_to 'Остальные', control_dislocations_path('q' => {'current_role_uic_equals' => uic.number}), :target => '_blank'
      end
    end
  end

  filter :number
  filter :region, :input_html => {:style => "width: 220px;"}

  controller do
    def scoped_collection
      DislocationControl.joins(:region).includes(:user_current_roles, :region)
    end
  end
end
