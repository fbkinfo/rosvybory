ActiveAdmin::Event.subscribe ActiveAdmin::Resource::RegisterEvent do |resource|
  resource.add_action_item(only: [:index]) do
    _show_all = params[:show_all] && params[:show_all].to_sym == :true
    _label = I18n.t('views.pagination.actions.pagination_' + (_show_all ? 'on' : 'off'))
    link_to _label, control_users_path(params.except(:commit, :format).merge(:show_all => !_show_all))
  end

  resource.controller.class_eval do
    def apply_pagination(chain)
      return super.per(params[:show_all] && params[:show_all].to_sym == :true ? 1000000 : nil)
    end
  end
end
