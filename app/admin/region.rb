ActiveAdmin.register Region do

  menu :parent => I18n.t('active_admin.menu.dictionaries'), :if => proc{ can? :manage, Region }

  index do
    column :id
    column :kind do |region|
      region.kind.text
    end

    column :name
    column :has_tic
    actions
  end

end
