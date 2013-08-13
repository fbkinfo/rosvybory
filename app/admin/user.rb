ActiveAdmin.register User do
  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :region
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "Пользовательские данные" do
      f.input :roles
      f.input :email
      f.input :region
    end
    #f.inputs "Смена пароля" do
      #f.input :password
      #f.input :password_confirmation
    #end
    f.actions
  end

  controller do
    def permitted_params
      params.permit!
      params
    end

    def scoped_collection
      resource_class.includes(:region).includes(:roles) # prevent N+1 queries
    end

  end
end
