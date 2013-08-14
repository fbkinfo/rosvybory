ActiveAdmin.register Organisation do
  controller do
    def permitted_params
      params.permit!
    end
  end
end
