ActiveAdmin.register User do

  menu :if => proc{ can? :manage, User }

  collection_action :review, method: :get do
    @app = UserApp.find(params[:user_app_id])
    @user = User.new_from_app(@app)
    render "new"
  end

  scope :all, :default => true
  Role.all.each do |role|
    scope role.short_name do |items|
      items.where(:user_roles => {:role => role})
    end
  end if Role.table_exists?

  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :region
    column :organisation
    default_actions
  end

  filter :email

  form do |f|
    f.inputs "Пользовательские данные" do
      f.input :roles
      f.input :email
      f.input :phone
      f.input :adm_region
      f.input :region
      f.input :organisation
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
    end

    def scoped_collection
      resource_class.includes(:region).includes(:roles) # prevent N+1 queries
    end

  end
end
