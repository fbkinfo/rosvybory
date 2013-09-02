ActiveAdmin::Event.subscribe ActiveAdmin::Resource::RegisterEvent do |resource|

  # TODO move this into PaginatedCollection rendering
  resource.add_action_item(only: [:index]) do
    show_all = params[:show_all] == 'true'
    label = I18n.t('views.pagination.actions.pagination_' + (show_all ? 'on' : 'off'))
    link_to label, control_users_path(params.except(:commit, :format).merge(:show_all => !show_all))
  end

  resource.controller.class_eval do
    def apply_pagination(chain)
      params[:show_all] == 'true' ? super.per(1000000) : super
    end
  end
end
