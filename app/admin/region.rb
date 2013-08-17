ActiveAdmin.register Region do

  menu :if => proc{ can? :manage, Region }
end
