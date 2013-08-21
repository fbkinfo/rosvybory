ActiveAdmin.register Blacklist do
  menu :if => proc{ can? :manage, Blacklist }

  actions :all, except: [:show, :edit]

  controller do
    def permitted_params
      params.permit!
    end
  end
end
