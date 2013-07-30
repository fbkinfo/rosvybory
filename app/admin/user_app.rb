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
    column   :full_name
    #column   :last_name
    #column   :first_name
    #column   :patronymic
    #column   :phone
    column   :phone_formatted
    column   :email
    column("Округ") do  |user_app|
      region = user_app.region.try(:parent)
      link_to region.name, admin_region_path(region) if region
    end
    column   :region #, sortable: 'regions.name'

    column   :uic
    column(:has_car) {|user_app| user_app.has_car ? "Есть":"Нет"}
    column(:legal_status) {|user_app| legal_status_human_readable user_app.legal_status}
    column(:current_status) {|user_app| status_human_readable user_app.current_status}
    column(:desired_statuses) {|user_app| status_human_readable user_app.desired_statuses}
    column(:previous_statuses) {|user_app| status_human_readable user_app.previous_statuses}
    column   :experience_count
    column   :year_born
    column(:sex_male) {|user_app| user_app.sex_male ? "М":"Ж"}
    column   :extra
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

  #t.string   "social_accounts"
  #t.string   "app_code"
  #t.integer  "app_status"
  #t.datetime "created_at"
  #t.datetime "updated_at"

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
