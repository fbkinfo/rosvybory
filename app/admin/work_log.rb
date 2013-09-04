ActiveAdmin.register WorkLog do
  menu :parent => I18n.t('active_admin.menu.dictionaries'), :if => proc{ can? :manage, Organisation }

  actions :index, :show

  filter :user, :collection => proc { User.where(:id => WorkLog.select('distinct(user_id)')) }
  filter :name
  filter :state, :as => :select, :collection => proc { WorkLog.pluck('distinct(state)') }

  index do
    column :id
    column :user
    column :name
    column :params do |work_log|
      # render it on the client to save save cpu :)
      content_tag(:div, '', :data => {json: work_log.params})
    end
    column :state, :sortable => :state
    column :results do |work_log|
      content_tag(:div, '', :data => {json: work_log.results})
    end
  end

end
