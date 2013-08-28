class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:phone]

  def email_required?; false end

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :user_current_roles, dependent: :destroy, autosave: true
  has_many :current_roles, through: :user_current_roles  #роли наблюдателя/члена комиссии

  belongs_to :region
  belongs_to :adm_region, class_name: "Region"
  # belongs_to :mobile_group future stub
  belongs_to :organisation
  belongs_to :user_app

  validates :phone, presence: true, uniqueness: true, format: {with: /\A\d{10}\z/}

  after_create :mark_user_app_state
  after_create :send_sms_with_password, :if => :send_invitation?

  accepts_nested_attributes_for :user_current_roles, allow_destroy: true

  delegate :created_at, to: :user_app, allow_nil: true, prefix: true

  class << self
    def new_from_app(app)
      new.update_from_user_app(app)
    end

    def send_reset_password_instructions(attributes={})
      attributes["phone"] = Verification.normalize_phone_number(attributes["phone"])
      super
    end

    def find_for_database_authentication(conditions)
      conditions[:phone] = Verification.normalize_phone_number(conditions[:phone])
      super
    end
  end

  def has_role?(role_name)
    !!roles.exists?(slug: role_name)
  end

  def add_role(role_name)
    roles << Role.where(slug: role_name).first! unless roles.exists?(slug: role_name)
  end

  def remove_role(role_name)
    role = Role.where(slug: role_name).first!
    roles.delete role
  end

  # override Devise password recovery
  def send_reset_password_instructions
    generate_password
    save(validate: false)
    send_sms_with_password
  end

  def update_from_user_app(apps)
    apps = Array.wrap apps
    app = apps.first
    unless apps.size > 1
      self.email = app.email
      self.phone = Verification.normalize_phone_number(app.phone)
      self.user_app = app
      generate_password
    end
    if apps.map(&:adm_region_id).uniq.size == 1
      self.adm_region_id = app.adm_region_id
      if apps.map(&:region_id).uniq.size == 1
        self.region = app.region
      end
    end
    if apps.map(&:organisation_id).uniq.size == 1
      self.organisation = app.organisation
    end

    if apps.map(&:can_be_observer).uniq == [true]
      self.add_role :observer
    end
    common_roles =
        apps[1..-1].inject(app.user_app_current_roles.map(&:current_role)) do |list, app|
      list & app.user_app_current_roles.map(&:current_role)
    end
    logger.debug "User@#{__LINE__}#update_from_user_app #{app.current_roles.inspect} #{common_roles.inspect}" if logger.debug?
    if common_roles.present?
      app.user_app_current_roles.each do |ua_role|
        if common_roles.include? ua_role.current_role
          ucr = user_current_roles.find_or_initialize_by(current_role_id: ua_role.current_role.id)
          if apps.size == 1
            if ua_role.current_role.must_have_uic?
              ucr.uic = Uic.find_by(number: ua_role.value) || Uic.find_by(number: app.uic)
            elsif ua_role.current_role.must_have_tic?
              ucr.region = Region.find_by(name: ua_role.value)
              unless ucr.region
                if region.try(:has_tic?)#для районов с ТИКами
                  ucr.region = region
                elsif adm_region.try(:has_tic?) #для округов с ТИКами
                  ucr.region = adm_region
                end
              end
            end
          end   # if apps.size == 1
        end   # if common_roles.include? ua_role.current_role
      end   # app.user_app_current_roles.each
    end   # if common_roles.present?
    self
  end

  private

    def send_sms_with_password
      SmsService.send_message(phone, "Вход в РосВыборы: bit.ly/rosvybory, пароль: #{self.password}")
    end

    def generate_password
      self.password = "%08d" % [SecureRandom.random_number(100000000)]
    end

  def send_invitation?
    (%w{tc mc cc federal_repr} & roles.map{ |e| e.slug }).any?
  end

  def mark_user_app_state
    if user_app.present?
      user_app.approve!
    end
  end
end
