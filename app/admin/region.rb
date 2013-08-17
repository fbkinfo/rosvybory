ActiveAdmin.register Region do

  menu :if => proc{ can? :manage, Region }

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
