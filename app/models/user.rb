class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:phone]

  def email_required?; false end

  has_many :user_roles, dependent: :destroy, autosave: true
  has_many :roles, through: :user_roles

  has_many :user_current_roles, dependent: :destroy, autosave: true, inverse_of: :user
  validates_associated :user_current_roles

  has_many :current_roles, through: :user_current_roles  #роли наблюдателя/члена комиссии

  belongs_to :region
  belongs_to :adm_region, class_name: "Region"
  # belongs_to :mobile_group future stub
  belongs_to :organisation
  belongs_to :user_app

  attr_accessor :valid_roles

  validates :phone, presence: true, uniqueness: true, format: {with: /\A\d{10}\z/}

  validates :year_born,
            :numericality  => {:only_integer => true, :greater_than => 1900, :less_than => 2000,  :message => "Неверный формат", allow_nil: true}

  validate :roles_assignable, :if => :valid_roles

  after_create :mark_user_app_state
  after_create :send_sms_with_password, :if => :send_invitation?

  accepts_nested_attributes_for :user_current_roles, allow_destroy: true

  delegate :created_at, to: :user_app, allow_nil: true, prefix: true


  def full_name
    [last_name, first_name, patronymic].join ' '
  end

  def full_name=(name)
    split = name.split(' ', 3)
    self.last_name = split[0]
    self.first_name = split[1]
    self.patronymic = split[2]
  end

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
    user_roles.build :role_id => Role.where(slug: role_name).first!.id unless has_role?(role_name)
  end

  def remove_role(role_name)
    role = Role.where(slug: role_name).first!
    user_roles.each {|ur| ur.mark_for_destruction if ur.role_id == role.id }
  end

  def role_ids=(values)
    new_ids = values.reject(&:blank?).map(&:to_i).to_set
    user_roles.each do |ur|
      if new_ids.include?(ur.role_id)
        new_ids.delete ur.role_id
      else
        ur.mark_for_destruction
      end
    end
    new_ids.each do |role_id|
      user_roles.build :role_id => role_id
    end
  end

  # override Devise password recovery
  def send_reset_password_instructions
    generate_password
    save(validate: false)
    send_sms_with_password
  end

  def update_from_user_app(app)
    #TODO refactor
    self.last_name = app.last_name
    self.first_name = app.first_name
    self.patronymic = app.patronymic
    self.email = app.email
    self.region = app.region
    self.adm_region_id = app.adm_region_id
    self.phone = Verification.normalize_phone_number(app.phone)
    self.organisation = app.organisation
    self.year_born = app.year_born
    self.user_app = app
    generate_password

    if app.can_be_observer || app.user_app_current_roles.present?
      add_role :observer
      app.user_app_current_roles.each do |ua_role|
        if ua_role.current_role
          ucr = user_current_roles.find_or_initialize_by(current_role_id: ua_role.current_role.id)
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

    def roles_assignable
      changed_roles = user_roles.select {|ur| ur.new_record? || ur.marked_for_destruction?}
      bad_roles = changed_roles.select {|ur| !ur.role.in?(valid_roles) }
      if bad_roles.present?
        errors.add(:role_ids, "Вам нельзя изменять роль #{bad_roles.map(&:role_name).to_sentence} у пользователей")
      end
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
