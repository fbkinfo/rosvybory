class ExcelUserAppRow
  COLUMNS = {
    uid: 0,           #нет прямого поля
    created_at: 1,
    adm_region: 2,
    region: 3,
    last_name: 4,
    first_name: 5,
    patronymic: 6,
    phone: 7,
    email: 8,

    current_statuses: 10,
    experience_count: 11,
    previous_statuses: 12,
    can_be_reserv: 13,   #нет прямого поля
    can_be_coord_region: 14, #нет прямого поля

    has_car: 15,
    social_accounts: 16,
    extra: 17
  }.freeze

  class <<self
    def columns
      COLUMNS
    end

    def column_names
      @@column_names ||= columns.sort_by(&:last).map(&:first).freeze
    end

    def human_attribute_name(f)
      UserApp.human_attribute_name(f)
    end
  end

  attr_reader :user_app, :user
  attr_accessor :uid # lost after save
  attr_accessor :can_be_reserv

  delegate :organisation, :organisation=, :created_at, :adm_region, :region, :last_name, :first_name, :patronymic, :phone, :email, :current_statuses, :experience_count, :previous_statuses, :can_be_coord_region, :has_car, :social_accounts, :extra,
            :persisted?, :new_record?, :to => :user_app, :allow_nil => true

  def initialize(raw_attrs)
    attrs = {}.with_indifferent_access
    raw_attrs.each do |k,v|
      attrs[k] = v.strip if v.present?
    end
    attrs.delete '_destroy'

    phone = attrs[:phone]
    region = Region.find_by(name: attrs[:region])
    adm_region = Region.adm_regions.find_by(name: normalize_adm_region(attrs[:adm_region_name]))

    self.uid = attrs[:uid]
    @user_app = UserApp.find_or_initialize_by(phone: phone).tap do |a|
      a.email = attrs[:email]
      a.first_name = attrs[:first_name]
      a.last_name = attrs[:last_name]
      a.patronymic = attrs[:patronymic]

      a.region = region
      a.adm_region = adm_region

      a.social_accounts = attrs[:social_accounts]
      a.extra = attrs[:extra]

      a.phone_verified = true
      a.state = :approved

      a.has_car = attrs[:has_car] == ""

      # осталось заполнить оставшиеся поля
      # сейчас падает на валидации:
      # Готов стать Требуется выбрать хотя бы один вариант, Видеосъемка требуется указать, Юр. образование имеет непредусмотренное значение, Пол требуется указать, Год рождения требуется указать, Год рождения Неверный формат, ip требуется указать, Телефон не подтвержден
    end
    @user = @user_app.user || User.new_from_app(@user_app)
  end

  def errors
    @user_app.errors
  end

  def save
    @user_app.save && @user.save
    # @user_app.confirm!
  end

  private
    def normalize_adm_region(name)
      downcased = name.to_s.mb_chars.downcase
      case downcased
      when "цао"
        "Центральный АО"
      when "юао"
        "Южный АО"
      when "сао"
        "Северный АО"
      when "свао"
        "Северо-Восточный АО"
      when "вао"
        "Восточный АО"
      when "ювао"
        "Юго-Восточный АО"
      when "юзао"
        "Юго-Западный АО"
      when "зао"
        "Западный АО"
      when "сзао"
        "Северо-Западный АО"
      when "зелао"
        "Зеленоградский АО"
      when "нао"
        "Новомосковский АО"
      when "тао"
        "Троицкий АО"
      else
        name
      end
    end

end
