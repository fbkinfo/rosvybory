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
    column :params
    column :state, :sortable => :state
    column :results
  end

end
