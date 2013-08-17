ActiveAdmin.register Organisation do
  menu :if => proc{ can? :manage, Organisation }

  controller do
    def permitted_params
      params.permit!
    end
  end
end
