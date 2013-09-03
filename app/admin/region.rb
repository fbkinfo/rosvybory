ActiveAdmin.register Region do

  menu :parent => I18n.t('active_admin.menu.dictionaries'), :if => proc{ can? :manage, Region }
  batch_action :destroy, false

  index :download_links => false do
    column :id
    column :kind do |region|
      region.kind.text
    end

    column :name
    column :has_tic
    actions
  end

end
