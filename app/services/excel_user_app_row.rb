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
    uic: 9,

    current_statuses: 10,
    experience_count: 11,
    previous_statuses: 12,
    can_be_reserv: 13,   #нет прямого поля
    can_be_coord_region: 14, #нет прямого поля

    has_car: 15,
    social_accounts: 16,
    extra: 17
  }.freeze

  TRUTH = %w{1 да есть}.freeze

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
  attr_accessor :adm_region, :region, :has_car, :current_statuses, :experience_count, :previous_statuses, :can_be_coord_region, :can_be_reserv, :social_accounts

  delegate :organisation, :organisation=,
            # require no special treatment
            :first_name,  :last_name,  :patronymic,  :email,  :extra,  :phone,  :uic,  :created_at,
            :first_name=, :last_name=, :patronymic=, :email=, :extra=, :phone=, :uic=, :created_at=,
            # read-only
            :persisted?, :new_record?, :to => :user_app, :allow_nil => true

  def initialize(attrs)
    phone = Verification.normalize_phone_number(attrs[:phone])

    @user_app = UserApp.find_or_initialize_by(phone: phone) do |a|
      a.ip = '127.0.0.1'
      a.year_born = 1913
      a.sex_male = true
      a.has_video = false
      a.legal_status = UserApp::LEGAL_STATUS_NO
    end

    attrs.each do |k,v|
      v = v.strip if v.respond_to?(:strip)
      send "#{k}=", v if v.present? && k != '_destroy'
    end
    @user = @user_app.user || User.new_from_app(@user_app)
  end

  #     # осталось заполнить оставшиеся поля
  #     # сейчас падает на валидации:
  #     # Готов стать Требуется выбрать хотя бы один вариант, Видеосъемка требуется указать, Юр. образование имеет непредусмотренное значение, Пол требуется указать, Год рождения требуется указать, Год рождения Неверный формат, ip требуется указать, Телефон не подтвержден

  def current_statuses=(v)
    # raise v.inspect
    @current_statuses = v
  end

  def previous_statuses=(v)
    # raise v.inspect
    @previous_statuses = v
  end

  def social_accounts=(v)
    # raise v.inspect
    @social_accounts = v
  end

  def has_car=(v)
    @user_app.has_car = TRUTH.include?(v)
    @has_car = v
  end

  def can_be_coord_region=(v)
    @user_app.can_be_coord_region = TRUTH.include?(v)
    @can_be_coord_region = v
  end

  def can_be_reserv=(v)
    @user_app.can_be_prg_reserve = TRUTH.include?(v)
    @can_be_reserv = v
  end

  def adm_region=(v)
    @user_app.adm_region = Region.adm_regions.find_by(name: normalize_adm_region(v))
    @adm_region = v
  end

  def experience_count=(v)
    @user_app.experience_count = v.to_i
    @experience_count = v
  end

  def region=(v)
    @user_app.region = Region.find_by(name: v)
    @region = v
  end

  def errors
    @user_app.errors
  end

  def save
    success = @user_app.save && @user.save
    @user_app.confirm! if success
    success
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
