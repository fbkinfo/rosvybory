ActiveAdmin.register User do

  menu :if => proc{ can? :manage, User }

  collection_action :review, method: :get do
    @app = UserApp.find(params[:user_app_id])
    @user = User.new_from_app(@app)
    render "new", layout: false
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

  form :partial => "form"

  controller do
    def permitted_params
      params.permit!
    end

    def scoped_collection
      resource_class.includes(:region).includes(:roles) # prevent N+1 queries
    end

  end
end
