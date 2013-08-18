ActiveAdmin.register User do

  menu :if => proc{ can? :manage, User }

  scope :all, :default => true
  Role.all.each do |role|
    scope role.short_name do |items|
      items.where(:user_roles => {:role => role})
    end
  end if Role.table_exists?

  show do |user|
    if can? :manage, user #вид для админа
      attributes_table do
        row :email
        row :region
        row :organisation
        #row :roles
        row :current_sign_in_at
        row :last_sign_in_at
        row :sign_in_count
        row :created_at
        row :updated_at
      end
      active_admin_comments
    elsif can? :read, user
      attributes_table do
        row :email
        row :region
        row :organisation
      end
    end
  end

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
      f.input :region
      f.input :organisation
    end
    f.actions
  end

  member_action :edit_password do
    @user = User.find(current_user.id)
    @page_title = "Смена пароля"
  end

  action_item do
    link_to "Сменить пароль", edit_password_control_user_path(current_user) if user == current_user
  end

  controller do
    def permitted_params
      params.permit!
    end

    def password_params
      params.require(:user).permit([:current_password, :password, :password_confirmation])
    end

    def scoped_collection
      resource_class.includes(:region).includes(:roles) # prevent N+1 queries
    end

    def update
      if params[:user] && params[:user][:current_password]
        @user = User.find(current_user.id)
        if @user.update_with_password(password_params)
          # Sign in the user by passing validation in case his password changed
          sign_in @user, :bypass => true
          redirect_to edit_password_control_user_path(@user), :notice => "Пароль обновлён"
        else
          render :edit_password, layout: "active_admin"
        end
      else
        @user = User.find(params[:user])
        authorize! :assign_roles, @project
        update!
      end
    end

  end
end
