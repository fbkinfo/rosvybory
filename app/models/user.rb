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

  belongs_to :region
  belongs_to :adm_region, class_name: "Region"
  belongs_to :organisation

  class << self
    def new_from_app(app)
      new do |user|
        user.email = app.email
        user.region_id = app.region_id
        user.adm_region_id = app.adm_region_id
        #user.phone = app.phone.gsub(/[-\s]/, "")
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

  def send_sms_with_password(raw_password);end
end
