# encoding: utf-8

ActiveAdmin.register User do
  decorate_with UserDecorator

  actions :all, :except => [:new]

  menu :if => proc{ can? :crud, User }

  scope :all, :default => true
  Role.all.each do |role|
    scope role.short_name do |items|
      items.where(:user_roles => {:role => role})
    end
  end if Role.table_exists?

  scope 'Без ролей' do |items|
    items.where('NOT EXISTS (SELECT * FROM "user_roles" WHERE user_id = "users".id)')
  end

  scope 'Телефон в черном списке' do |items|
    items.where('EXISTS (SELECT * FROM blacklists WHERE phone=users.phone)')
  end

  batch_action :new_group_email do |selection|
    if (@users = User.where(id: selection)).blank?
      redirect_to :back, flash: {error: "Не выбран ни один получатель!"}
    else
      render template: 'user_apps/new_group_email', layout: 'custom_layout'
    end
  end
  batch_action :new_group_sms do |selection|
    if (@users = User.where(id: selection)).blank?
      redirect_to :back, flash: {error: "Не выбран ни один получатель!"}
    else
      render template: 'user_apps/new_group_sms', layout: 'custom_layout'
    end
  end
  batch_action :destroy, false

  show do |user|
    h3 'Внимание! Телефон пользователя занесён в чёрный список!' if user.blacklisted
    if can? :crud, user #вид для админа
      attributes_table do
        row :blacklist_info if user.blacklisted
        row :user_app
        row :organisation, &:organisation_with_user_id
        row :user_app_created_at
        row :full_name
        row :adm_region
        row :region
        row :phone
        row :email
        row :uic
        row :user_current_roles
        row :roles, &:human_roles
        row :experience_count
        row :previous_statuses, &:human_previous_statuses
        row :can_be_coord_region
        row :can_be_caller
        row :can_be_mobile
        row :has_car, &:human_has_car
        row :legal_status, &:human_legal_status
        row :has_video, &:human_has_video
        row :extra
        row :address
        row :passport
        row :place_of_birth
        row :work
        row :work_position

        row :last_sign_in_at
        row :sign_in_count
        row :created_at
        row :updated_at
      end
      render :partial => 'user_apps/social_links', :locals => {:user_app => user.user_app}
      active_admin_comments
    elsif can? :read, user
      attributes_table do
        row :full_name
        row :email
        row :region
        row :organisation
      end
    end
  end

  index :download_links => [:xlsx] do
    selectable_column
    actions(defaults: false) do |resource|
      links = ''.html_safe
      links << link_to(I18n.t('active_admin.view'), resource_path(resource), class: "member_link view_link")
      links << '<br/> <br/>'.html_safe
      links << link_to(I18n.t('active_admin.edit'), edit_user_path(resource.id), class: "member_link edit_link")
      links << '<br/> <br/>'.html_safe
      links << link_to(I18n.t('active_admin.delete'), resource_path(resource), class: "member_link delete_link", method: :delete, data: { confirm: "Вы уверены? Удаление пользователя нельзя будет отменить" })
      links
    end

    column "НО + id", &:organisation_with_user_id
    column :created_at
    column :adm_region, :sortable => :adm_region_id
    column :region, :sortable => :region_id
    column :full_name
    column :phone do |user|
      %Q(<span #{user.wrong_phone ? 'style="color: red;" title="Некорректный номер, смс не доходят"' : ''}>#{user.phone}</span>).html_safe
    end
    column :email
    column :uic, :sortable => 'user_apps.uic'

    column :current_roles, &:human_current_roles
    column :roles, &:human_roles
    column :user_current_roles
    column :experience_count
    column :previous_statuses, &:human_previous_statuses
    column :can_be_coord_region
    column :can_be_caller
    column :can_be_mobile
    column :has_car, &:human_has_car
    column :legal_status, &:human_legal_status
    column :has_video, &:human_has_video
    column :social_accounts, &:human_social_accounts
    column :extra
    column :year_born
  end

  filter :adm_region, :as => :select, :collection => proc { Region.adm_regions }
  filter :region, :as => :select, :collection => proc { Region.mun_regions }
  filter :organisation, label: 'Организация', as: :select, collection: proc { Organisation.order(:name) }
  filter :roles
  filter :user_current_roles_current_role_id, label: 'Роль наблюдателя', as: :select, collection: proc { CurrentRole.all }
  filter :user_app_uic_matcher, as: :string, label: '№ УИК'
  filter :full_name
  filter :phone
  filter :wrong_phone
  filter :email
  filter :user_app_created_at, as: :date_range, label: 'Дата подачи заявки'
  filter :created_at, label: 'Дата создания'
  filter :user_app_experience_count, :as => :numeric, label: 'Опыт'
  filter :user_app_has_car, as: :boolean, label: 'Автомобиль'
  filter :user_app_has_video, as: :boolean, label: 'Видеосъёмка'
  filter :dislocated, as: :select, collection: [['Есть', 'true'], ['Нет', 'false']], label: 'Расстановка'

  filter :year_born, as: :numeric_range

  form :partial => 'form'

  config.action_items.clear

  member_action :edit_password do
    @user = User.find(current_user.id)
    @page_title = "Смена пароля"
  end

  action_item(only: [:show]) do
    link_to "Сменить пароль", edit_password_control_user_path(current_user) if user == current_user
  end

  controller do

    def index
      if request.format.symbol == :xlsx
        xr = XlsxRenderer.new(User)
        xr.iterate collection do
          column "НО + id", &:organisation_with_user_id
          column :created_at
          column :adm_region
          column :region
          column :full_name
          column :phone do |user| " #{user.phone}" end # prevent excel treating phone as number or date
          column :email
          column :uic

          column :current_roles, &:human_current_roles
          column :roles, &:human_roles
          column :user_current_roles
          column :experience_count
          column :previous_statuses, &:human_previous_statuses
          column :can_be_coord_region
          column :can_be_caller
          column :can_be_mobile
          column :has_car, &:human_has_car
          column :legal_status, &:human_legal_status
          column :has_video, &:human_has_video
          column :social_accounts, &:human_social_accounts
          column :extra
          column :year_born
        end

        send_data xr.data, :filename => 'users.xlsx'
      else
        super
      end
    end

    def permitted_params
      params.permit!
    end

    def password_params
      params.require(:user).permit([:current_password, :password, :password_confirmation])
    end

    def scoped_collection
      resource_class.includes(:adm_region, :region, :roles, :user_app, :organisation) # prevent N+1 queries
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
      end
    end
  end
end
