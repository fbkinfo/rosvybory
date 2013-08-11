ActiveAdmin.register UserApp do
  member_action :reject, method: :post do
    user_app = resource
    user_app.reject!
    redirect_to control_user_app_path(user_app)
  end

  action_item only: [:edit, :show] do
    link_to('Отклонить', reject_control_user_app_path(user_app), method: :post) unless user_app.rejected?
  end


  #scope :all, :default => true
  #scope :trash
  #scope :accepted
  #scope :unchecked
  #
  ## Filterable attributes on the index screen

  filter :created_at
  filter :adm_region , :as => :select, :collection => proc { Region.adm_regions.all }, :input_html => {:style => "width: 220px;"}
  filter :region, :as => :select, :collection => proc { Region.mun_regions.all }, :input_html => {:style => "width: 220px;"}
  #так красиво разбивается по округам, но при фильтрации не устанавливает значение в текущее после перезагрузки страницы, это может сбить с толку
  #filter :region, :as => :select, :collection => proc { option_groups_from_collection_for_select(Region.adm_regions, :regions, :name, :id, :name) }


  filter   :last_name
  filter   :first_name
  filter   :patronymic
  filter   :phone
  filter   :email
  filter   :uic, :as => :numeric_range

  #filter   :current_status, :as => :bitwise_and, :collection =>  proc { UserApp.all_current_statuses.keys }, :input_html => {:style => "width: 220px;"}

  filter   :experience_count
  #column(:previous_statuses) {|user_app| status_human_readable user_app.previous_statuses}

  #column("Согласен войти в резерв УИКов") {|user_app| user_app.can_be_prg_reserve ? "Да":"Нет"}
  #column(:can_be_coord_region) {|user_app| user_app.can_be_coord_region ? "Да":"Нет"}
  #
  filter   :has_car
  #
  #column(:social_accounts) {|user_app| raw social_accounts_readable(user_app.social_accounts) }
  filter   :extra
  #column(:legal_status) {|user_app| legal_status_human_readable user_app.legal_status}

  #column(:legal_status) {|user_app| user_app.legal_status & UserApp::LEGAL_STATUS_YES ? "Да":"Нет"}
  #column("Адвокатский статус") {|user_app| user_app.legal_status == UserApp::LEGAL_STATUS_LAWYER ? "Да":"Нет"}
  #column(:desired_statuses) {|user_app| status_human_readable user_app.desired_statuses}
  #
  filter   :year_born, :as => :numeric_range
  #column(:sex_male) {|user_app| user_app.sex_male ? "М":"Ж"}
  filter   :ip
  filter   :useragent

  #preserve_default_filters!

  #scope :all, :default => true
  #Region.adm_regions.all.each do |adm_region|
  #  scope adm_region.name do |items|
  #    items.where(:adm_region => adm_region)
  #  end
  #end

  config.sort_order = "id_asc"
  controller do
    def scoped_collection
      resource_class.includes(:region).includes(:adm_region) # prevents N+1 queries to your database
    end

    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    column   :id
    column   :created_at
    #column("Адм. Округ") do  |user_app|
    #  region = user_app.region.try(:parent)
    #  link_to region.name, admin_region_path(region) if region
    #end
    column   :adm_region
    column   :region #, sortable: 'regions.name'
    column   :full_name
    #column   :last_name
    #column   :first_name
    #column   :patronymic
    #column   :phone
    column   :phone_formatted
    column   :email

    column   :uic
    column(:current_status) {|user_app| status_human_readable user_app.current_status}
    column   :experience_count
    column(:previous_statuses) {|user_app| status_human_readable user_app.previous_statuses}

    #column("Согласен войти в резерв УИКов") {|user_app| user_app.can_be_prg_reserve ? "Да":"Нет"}
    column(:can_be_coord_region) {|user_app| user_app.can_be_coord_region ? "Да":"Нет"}

    column(:has_car) {|user_app| user_app.has_car ? "Есть":"Нет"}

    column(:social_accounts) {|user_app| raw social_accounts_readable(user_app.social_accounts) }
    column   :extra
    column(:legal_status) {|user_app| legal_status_human_readable user_app.legal_status}

    #column("Юр.образование") {|user_app| user_app.legal_status & UserApp::LEGAL_STATUS_YES ? "Да":"Нет"}
    #column("Адвокатский статус") {|user_app| user_app.legal_status == UserApp::LEGAL_STATUS_LAWYER ? "Да":"Нет"}
    column(:desired_statuses) {|user_app| status_human_readable user_app.desired_statuses}

    column   :year_born
    column(:sex_male) {|user_app| user_app.sex_male ? "М":"Ж"}
    column   :ip
    column   :useragent
    #UserApp.future_statuses_methods.each do | method_name|
    #  column("Готов стать: "+t('activerecord.attributes.user_app.'+method_name), method_name) {|user_app| user_app.send(method_name) ? "Да" : "Нет" }
    #end
    #UserApp.previous_statuses_methods.each do | method_name|
    #  column("Есть опыт: "+t('activerecord.attributes.user_app.'+method_name), method_name) {|user_app| user_app.send(method_name) ? "Да" : "Нет" }
    #end

    default_actions
  end

  form do |f|
    f.inputs "Роль" do
      # TODO
      f.input :desired_statuses
      f.input :adm_region
      f.input :region
      f.input :uic
    end

    f.inputs "Личные данные" do
      f.input :last_name
      f.input :first_name
      f.input :patronymic
      f.input :phone
      f.input :phone_verified
      f.input :email
      f.input :year_born
      f.input :sex_male, label: "Мужчина"
    end

    f.inputs "Подробнее" do
      # TODO
      f.input :current_status
      f.input :has_car
      f.input :legal_status
    end

    f.inputs "Прежний опыт" do
      # TODO
      f.input :previous_statuses
      f.input :experience_count
    end

    f.inputs "Аккаунты в соцсетях" do
      # TODO
      #f.input :social_accounts
    end

    f.inputs "Дополнительные сведения" do
      f.input :extra
    end

    f.actions
  end

  csv do
    column   :id
    column   :created_at
    column   :adm_region
    column   :region
    #column   :full_name
    column   :last_name
    column   :first_name
    column   :patronymic
     #column   :phone
    column   :phone_formatted
    column   :email

    column   :uic
    column(:current_status) {|user_app| status_human_readable user_app.current_status}
    column   :experience_count
    column(:previous_statuses) {|user_app| status_human_readable user_app.previous_statuses}

    column("Согласен войти в резерв УИКов") {|user_app| nil}
    column(:can_be_coord_region) {|user_app| user_app.can_be_coord_region ? "Да":"Нет"}

    column(:has_car) {|user_app| user_app.has_car ? "Есть":"Нет"}

    column   :social_accounts
    column   :extra

    #column(:legal_status) {|user_app| legal_status_human_readable user_app.legal_status}
    column("Юр.образование") {|user_app| user_app.legal_status & UserApp::LEGAL_STATUS_YES ? "Да":"Нет"}
    column("Адвокатский статус") {|user_app| user_app.legal_status == UserApp::LEGAL_STATUS_LAWYER ? "Да":"Нет"}

    column(:desired_statuses) {|user_app| status_human_readable user_app.desired_statuses}

    column   :year_born
    column(:sex_male) {|user_app| user_app.sex_male ? "М":"Ж"}
    column   :ip
    column   :useragent

    UserApp.future_statuses_methods.each do | method_name|
      column(method_name) {|user_app| user_app.send(method_name) ? "Да" : "Нет" }
    end
    UserApp.previous_statuses_methods.each do | method_name|
      column(method_name) {|user_app| user_app.send(method_name) ? "Да" : "Нет" }
    end


  end
end
