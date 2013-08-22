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

  has_many :user_current_roles, dependent: :destroy
  has_many :current_roles, through: :user_current_roles

  belongs_to :region
  belongs_to :adm_region, class_name: "Region"
  belongs_to :mobile_group # future stub
  belongs_to :organisation
  belongs_to :user_app

  validates :phone, presence: true

  after_create :mark_user_app_state
  after_create :send_sms_with_password

  accepts_nested_attributes_for :user_current_roles, allow_destroy: true

  delegate :created_at, to: :user_app, allow_nil: true, prefix: true

  class << self
    def new_from_app(app)
      new do |user|
        user.email = app.email
        user.region_id = app.region_id
        user.adm_region_id = app.adm_region_id
        user.phone = app.phone.gsub(/[^\d+]/, '')
        user.organisation_id = app.organisation_id
        user.user_app_id = app.id
        user.password = "%08d" % [SecureRandom.random_number * 100000000]
      end
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

  def send_sms_with_password
    SmsService.send_message(phone, "Вход в РосВыборы: bit.ly/rosvybory, пароль: #{self.password}") if send_invitation?
  end

  private

  def send_invitation?
    (%w{tc mc cc federal_repr} & roles.map{ |e| e.slug }).any?
  end

  def mark_user_app_state
    if user_app.present?
      user_app.approve!
    end
  end
end
