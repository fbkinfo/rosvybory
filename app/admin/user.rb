ActiveAdmin.register User do

  menu :if => proc{ can? :manage, User }

  scope :all, :default => true
  Role.all.each do |role|
    scope role.short_name do |items|
      items.where(:user_roles => {:role => role})
    end
  end if Role.table_exists?
  
  batch_action :new_group_email
  batch_action :other

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

  #TODO: Нужен рефакторинг
  index do
    selectable_column
    column :created_at
    column "ФИО" do |user|
      user.user_app ? UserAppDecorator.decorate(user.user_app).full_name : ''
    end
    column :phone
    column :email
    column "НО + id" do |user|
      user.organisation ? "#{user.organisation.name}-#{user.id}" : ''
    end
    column :adm_region
    column :region
    column "№ УИК" do |user|
      user.user_app.try(:decorate).try(:uic)
    end
    column "Готов стать" do |user|
      user.user_app.try(:decorate).try(:desired_statuses)
    end
    column "Пол" do |user|
      user.user_app.try(:decorate).try(:sex_male)
    end
    column "Текущие статусы" do |user|
      user.user_app.try(:decorate).try(:current_roles)
    end
    column "Прежний опыт: количество раз" do |user|
      user.user_app.try(:experience_count)
    end
    column "Прежний опыт: статусы" do |user|
      user.user_app.try(:decorate).try(:previous_statuses)
    end
    column "Может быть ТК" do |user|
      user.user_app.try(:decorate).try(:can_be_coord_region)
    end
    column "Может быть оп. КЦ" do |user|
      user.user_app.try(:decorate).try(:can_be_caller)
    end
    column "Может быть уч. моб. гр." do |user|
      user.user_app.try(:decorate).try(:can_be_mobile)
    end
    column "Автомобиль" do |user|
      user.user_app.try(:decorate).try(:has_car)
    end
    column "Видеосъёмка" do |user|
      user.user_app.try(:decorate).try(:has_video)
    end
    column "Юр.образование" do |user|
      user.user_app.try(:decorate).try(:legal_status)
    end

    column "Соцсети" do |user|
      user.user_app.try(:decorate).try(:social_accounts)
    end
    column "Дополнительные сведения" do |user|
      user.user_app.try(:decorate).try(:extra)
    end

    default_actions
  end

  filter :email
  filter :user_app_created_at, as: :date_range, label: 'Дата подачи заявки'
  filter :created_at, label: 'Дата создания'
  filter :user_app_experience_count, :as => :numeric, label: 'Опыт'
  filter :adm_region, :as => :select, :collection => proc { Region.adm_regions.all }, :input_html => {:style => "width: 220px;"}
  filter :region, :as => :select, :collection => proc { Region.mun_regions.all }, :input_html => {:style => "width: 220px;"}

  form :partial => "form"

  config.action_items.clear

  member_action :edit_password do
    @user = User.find(current_user.id)
    @page_title = "Смена пароля"
  end

  action_item(only: [:show]) do
    link_to "Сменить пароль", edit_password_control_user_path(current_user) if user == current_user
  end

  controller do
    def permitted_params
      params.permit!
    end

    def password_params
      params.require(:user).permit([:current_password, :password, :password_confirmation])
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
