ActiveAdmin.register UserApp do

  menu :label => "Заявки"
  config.sort_order = "id_asc"
  controller do
    def scoped_collection
      resource_class.includes(:region) # prevents N+1 queries to your database
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

    #column(:legal_status) {|user_app| user_app.legal_status & UserApp::LEGAL_STATUS_YES ? "Да":"Нет"}
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

  csv do
    column   :id
    column   :created_at
    column   :adm_region
    #column("Адм. Округ") do  |user_app|
    #  user_app.region.try(:parent).try(:name)
    #end
    column   :region #, sortable: 'regions.name'
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

    #column("Согласен войти в резерв УИКов") {|user_app| user_app.can_be_prg_reserve ? "Да":"Нет"}
    column(:can_be_coord_region) {|user_app| user_app.can_be_coord_region ? "Да":"Нет"}

    column(:has_car) {|user_app| user_app.has_car ? "Есть":"Нет"}

    column   :social_accounts
    column   :extra

    column(:legal_status) {|user_app| legal_status_human_readable user_app.legal_status}
    #column(:legal_status) {|user_app| user_app.legal_status & UserApp::LEGAL_STATUS_YES ? "Да":"Нет"}
    #column("Адвокатский статус") {|user_app| user_app.legal_status == UserApp::LEGAL_STATUS_LAWYER ? "Да":"Нет"}

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

  #t.string   "app_code"
  #t.integer  "app_status"

  ## Creat e sections on the index screen
  #scope :all, :default => true
  #scope :available
  #scope :drafts
  #
  ## Filterable attributes on the index screen
  #filter :title
  #filter :author, :as => :select, :collection => lambda{ Product.authors }
  #filter :price
  #filter :created_at
  #
  ## Customize columns displayed on the index screen in the table
  #index do
  #  column :title
  #  column "Price", :sortable => :price do |product|
  #    number_to_currency product.price
  #  end
  #  default_actions
  #end

end
