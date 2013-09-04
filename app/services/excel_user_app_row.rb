class ExcelUserAppRow
  extend Enumerize
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

    current_roles: 10, #инициализия этого поля требует уже инициализированных полей uic, region и adm_region, поэтому в этом хеше оно должно идти после них.
    experience_count: 11,
    previous_statuses: 12,
    can_be_reserv: 13,   #нет прямого поля
    can_be_coord_region: 14, #нет прямого поля

    has_car: 15,
    social_accounts: 16,
    extra: 17
  }.freeze

  TRUTH = %w{1 1.0 да есть}.freeze

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

  attr_accessor :import_status
  enumerize :import_status, in: [:created , :updated, :ignored, :failed]
  attr_accessor :import_error

  def fail_with(error)
    self.import_status = :failed
    self.import_error = error
  end

  attr_reader :user_app, :user
  attr_accessor :uid # lost after save, but is used to detect organisation
  attr_accessor :created_at, :adm_region, :region, :has_car, :current_roles, :experience_count, :previous_statuses, :can_be_coord_region, :can_be_reserv, :social_accounts, :uic
  attr_accessor :first_name, :last_name, :patronymic, :email, :extra, :phone

  delegate :id, :organisation, :persisted?, :new_record?, :to => :user_app, :allow_nil => true

  def initialize(attrs, update_existing = false)
    phone = Verification.normalize_phone_number(attrs[:phone])
    @update_existing = update_existing
    @user_app = UserApp.find_or_initialize_by(phone: phone) do |a|
      a.ip ||= '127.0.0.1'
      a.year_born ||= 1913
      a.sex_male = true if a.sex_male.nil?
      a.has_video = false if a.has_video.nil?
      a.has_car = false if a.has_car.nil?
      a.legal_status ||= UserApp::LEGAL_STATUS_NO
    end
    @user_app.imported!
    @user_app.can_be_observer = true

    if local_only = phone.blank?
      Rails.logger.info "User import - no phone in #{attrs[:uid]}" if attrs[:uid].present?
      fail_with "Поле с телефоном - пустое. Первый столбец - #{attrs[0]}"
    end

    self.class.column_names.each do |k|
      v = attrs[k]
      v = v.strip if v.respond_to?(:strip)
      if local_only
        instance_variable_set("@#{k}", v)
      else
        send "#{k}=", v if v.present?
      end
    end
  end

  def uid=(v)
    orgs_by_name = {
        "ГН" => "Гражданин Наблюдатель",
        "ГЛС" => "Голос",
        "СНР" => "Сонар"
    }
    self.organisation = Organisation.where(name: orgs_by_name[v.to_s.split('-')[0]]).first
  end

  def current_roles=(v)
    roles_by_name = {
      "РЗ" => 'reserve',
      "УПРГ" => 'prg',
      "ТПСГ" => 'psg_tic',
      "ТПРГ" => 'prg_tic'
    }
    role = CurrentRole.where(:slug => roles_by_name[v]).first
    if role && !@user_app.user_app_current_roles.where(:current_role_id => role.id).first
      value = nil
      if role.must_have_uic?
        value = "#{@user_app.uic}"
      elsif role.must_have_tic?
        if region.try(:has_tic?)#для районов с ТИКами
          value = region.name
        elsif adm_region.try(:has_tic?) #для округов с ТИКами
          value = adm_region.name
        end
      end
      @user_app.user_app_current_roles.build(:current_role_id => role.id, value: value).keep = '1'
    end
  end

  def previous_statuses=(v)
    statuses_by_name = {
      "ОК" => UserApp::STATUS_OBSERVER,
      "ПРГ" => UserApp::STATUS_PRG,
      "МГ" => UserApp::STATUS_MOBILE,
      "ТИК" => UserApp::STATUS_TIC_PSG,
      "ДК" => UserApp::STATUS_DELEGATE
    }
    if status_value = statuses_by_name[v.to_s.strip.mb_chars.upcase.to_s]
      @user_app.previous_statuses |= status_value
    end
    self.experience_count = @experience_count if @experience_count
  end

  def social_accounts=(v)
    # TODO when better times come
    # accounts_urls = v.to_s.scan(/http?:\/\/[\w\/\.]*/)
    # known_networks = { vk: /vk.com/, ... }
    # accounts_urls.each {|u| find_network and set in @user_app }
  end

  def has_car=(v)
    @user_app.has_car = TRUTH.include?(v.to_s)
  end

  def can_be_coord_region=(v)
    @user_app.can_be_coord_region = TRUTH.include?(v.to_s)
  end

  def can_be_reserv=(v)
    @user_app.can_be_prg_reserve = TRUTH.include?(v.to_s)
  end

  def adm_region=(v)
    @user_app.adm_region = Region.adm_regions.find_by(name: normalize_adm_region(v).to_s)
  end

  def experience_count=(v)
    if @user_app.previous_statuses > 0
      @user_app.experience_count = v.to_i if v.to_i > 0
    else
      @user_app.experience_count = 0
    end
  end

  def uic=(v)
    @user_app.uic = v.to_i if v.to_i > 0
  end

  def region=(v)
    @user_app.region = Region.find_by(name: v.to_s)
  end

  def organisation=(org)
    @user_app.organisation = org
  end

  def created_at=(v)
    @user_app.created_at = v rescue nil # convert to datetime
    @created_at = @user_app.created_at
  end

  ['first_name', 'last_name', 'patronymic', 'email', 'extra', 'phone'].each do |field|
    define_method "#{field}=" do |value|
      @user_app.send "#{field}=", value
    end
  end

  COLUMNS.each do |field, _dummy|
    define_method "#{field}_with_localstore=" do |v|
      instance_variable_set("@#{field}", v)
      send "#{field}_without_localstore=", v
    end
    alias_method_chain "#{field}=", :localstore
  end

  def errors
    @user_app.errors
  end

  def minimally_valid?
    @user_app.phone.present?
  end

  def save
    @user_app.skip_phone_verification = true
    @user_app.skip_email_confirmation = true
    if @update_existing || !@user_app.user
      success =  @user_app.save
      if success
        if @user_app.user
          self.import_status = :updated
          Rails.logger.info "User import - updating user #{@user_app.user.phone}"
        else
          self.import_status = :created
          Rails.logger.info "User import - creating user #{@user_app.phone}"
        end
      else
        Rails.logger.info "User import - could not save user_app #{@user_app.phone} #{@user_app.errors.full_messages.join('; ')}"
        fail_with "Не удалось сохранить заявку с телефоном #{@user_app.phone}: #{@user_app.errors.full_messages.join('; ')}"
      end
    else
      success = false
      self.import_status = :ignored
      Rails.logger.info "User import - ignoring existing user #{@user_app.user.phone}"
    end
    if success
      @user_app.confirm!
      @user = @user_app.user || User.new
      @user.update_from_user_app(@user_app, false)
      if success = @user.save
        @user.update_column :created_at, created_at if created_at
      else
        Rails.logger.info "User import error - could not save user #{@user.phone} #{@user.errors.full_messages.join('; ')}"
        fail_with "Не удалось сохранить пользователя с телефоном #{@user.phone}: #{@user.errors.full_messages.join('; ')}"
      end
    end
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
