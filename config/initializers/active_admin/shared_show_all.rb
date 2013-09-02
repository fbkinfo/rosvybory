ActiveAdmin::Event.subscribe ActiveAdmin::Resource::RegisterEvent do |resource|

  # TODO move this into PaginatedCollection rendering
  resource.add_action_item(only: [:index]) do
    large_pages = params[:large_pages] == 'true'
    label = I18n.t('views.pagination.actions.pagination_' + (large_pages ? 'on' : 'off'))
    link_to label, params.except(:commit, :format).merge(:large_pages => !large_pages)
  end

  resource.controller.class_eval do
    def apply_pagination(chain)
      params[:large_pages] == 'true' ? super.per(200) : super
    end
  end
end
