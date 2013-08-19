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

  #TODO: Нужен рефакторинг
  index do
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
    column "Автомобиль" do |user|
      user.user_app.try(:decorate).try(:has_car)
    end
    column "Видеосъёмка" do |user|
      user.user_app.try(:decorate).try(:has_video)
    end
    column "Юр.образование" do |user|
      if user.user_app
        user.user_app.legal_status & UserApp::LEGAL_STATUS_YES ? "Да":"Нет"
      end
    end
    column "Адвокатский статус" do |user|
      if user.user_app
        user.user_app.legal_status & UserApp::LEGAL_STATUS_LAWYER ? "Да":"Нет"
      end
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

  form :partial => "form"

  config.action_items.clear

  controller do
    def permitted_params
      params.permit!
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
