class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:phone]

  validates_presence_of :phone
  validates_uniqueness_of :phone
  validates_format_of :phone, with: /\A\d{10}\z/

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :user_current_roles, dependent: :destroy, autosave: true
  has_many :current_roles, through: :user_current_roles  #роли наблюдателя/члена комиссии

  belongs_to :region
  belongs_to :adm_region, class_name: "Region"
  belongs_to :mobile_group # future stub
  belongs_to :organisation
  belongs_to :user_app

  validates :phone, presence: true

  after_create :mark_user_app_state
  after_create :send_sms_with_password, :if => :send_invitation?

  accepts_nested_attributes_for :user_current_roles, allow_destroy: true

  delegate :created_at, to: :user_app, allow_nil: true, prefix: true

  class << self
    def new_from_app(app)
      new.update_from_user_app(app)
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

  def update_from_user_app(app)
    self.email = app.email
    self.region = app.region
    self.adm_region_id = app.adm_region_id
    self.phone = Verification.normalize_phone_number(app.phone)
    self.organisation = app.organisation
    self.user_app = app
    generate_password

    if app.can_be_observer || app.user_app_current_roles.present?
      # FIXME isn't it excel_user_app_row-specific?
      self.add_role :observer
      app.user_app_current_roles.each do |ua_role|
        #TODO Откуда-то берётся дополнительная запись о Резеве УИКов, надо разобраться откуда и убрать её
        if ua_role.current_role
          ucr = user_current_roles.find_or_initialize_by(current_role_id: ua_role.current_role.id)
          #"reserve" - без УИК и ТИК
          if ["psg", "prg"].include? ua_role.current_role.slug
            ucr.uic = Uic.find_by(number: app.uic)
          elsif ["psg_tic", "prg_tic"].include? ua_role.current_role.slug
            ucr.region = region if region.has_tic? #TODO Если указан район без ТИК, то возможно стоит кидать ошибку
          end
        end
      end
    end
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
