ActiveAdmin.register User do
  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "Пользовательские данные" do
      f.input :roles
      f.input :email
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
  end
end
