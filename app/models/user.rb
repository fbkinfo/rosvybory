# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:phone]

  def email_required?; false end

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles, 
    :after_add => :check_permissions,
    :after_remove => :check_permissions

  has_many :user_current_roles, dependent: :destroy, autosave: true, inverse_of: :user
  validates_associated :user_current_roles

  has_many :current_roles, through: :user_current_roles  #роли наблюдателя/члена комиссии

  belongs_to :region
  belongs_to :adm_region, class_name: "Region"
  # belongs_to :mobile_group future stub
  belongs_to :organisation
  belongs_to :user_app

  validates :phone, presence: true, uniqueness: true, format: {with: /\A\d{10}\z/}

<<<<<<< HEAD
  attr_accessor :current_user
=======
  validates :year_born,
            :numericality  => {:only_integer => true, :greater_than => 1900, :less_than => 2000,  :message => "Неверный формат", allow_nil: true}
>>>>>>> develop

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
      self.add_role :observer
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

    def check_permissions(record)
      # Story 55070698.
      #
      # АДМ, ФП и ТК могут изменить роль волонтёра в системе, выбрав роль из перечня:
      #  - член избирательной комисии / наблюдатель на участке
      #  - участник мобильных групп
      #  - оператор контакт-центра
      #  - координатор мобильных групп
      #  - координатор контакт-центра
      #
      # АДМ и ФП могут изменить роль волонтёра на указанные выше + ТК.
      #
      # АДМ может изменить роль волонтёра на указанные выше + ФП.
      _role = record.slug.to_sym
      raise ActiveRecord::ActiveRecordError, "Недостаточно полномочий для назначения/снятия роли '#{record.name}'" unless
        current_user.has_role?(:tc) && [:observer, :mobile, :callcenter, :mc, :cc].include?(_role) ||
        current_user.has_role?(:federal_repr) && [:observer, :mobile, :callcenter, :mc, :cc, :tc].include?(_role) ||
        current_user.has_role?(:admin) && [:observer, :mobile, :callcenter, :mc, :cc, :tc, :federal_repr].include?(_role)
    end

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
