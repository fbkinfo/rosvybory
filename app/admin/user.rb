ActiveAdmin.register User do

  menu :if => proc{ can? :manage, User }

  collection_action :review, method: :get do
    @app = UserApp.find(params[:user_app_id])
    if @app.reviewed?
      redirect_to action: :index, notice: "Заявка уже обработана"
    else
      @user = User.new_from_app(@app)
      @user.user_current_roles.build(user_id: @user.id)
      render "new"
    end
  end

  
  scope :all, :default => true
  Role.all.each do |role|
    scope role.short_name do |items|
      items.where(:user_roles => {:role => role})
    end
  end if Role.table_exists?
  
  batch_action :new_group_email
  batch_action :other

  index do
    selectable_column
    column :email
    column :phone
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :region
    column :organisation
    default_actions
  end

  filter :email

  form :partial => "form"

  config.action_items.clear

  controller do
    def permitted_params
      params.permit!
    end

    def batch_action
      redirect_to send(params[:batch_action] + '_path', params: params)
    end

    def scoped_collection
      resource_class.includes(:region).includes(:roles) # prevent N+1 queries
    end

    before_filter :expose_current_roles

    def expose_current_roles
      gon.current_roles = Hash[CurrentRole.pluck(:id, :slug)]
      gon.observer_role_id = Role.where(slug: "observer").first.id
    end
  end
end
