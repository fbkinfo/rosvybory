class UserApp < ActiveRecord::Base
  serialize :social_accounts, HashWithIndifferentAccess
  belongs_to :region
  belongs_to :adm_region, class_name: "Region"
  belongs_to :organisation
  has_many :user_app_current_roles, dependent: :destroy
  has_many :current_roles, through: :user_app_current_roles
  accepts_nested_attributes_for :user_app_current_roles

  #наблюдатель, участник мобильной группы, территориальный координатор, координатор мобильной группы, оператор горячей линии
  NO_STATUS, STATUS_OBSERVER, STATUS_MOBILE, STATUS_COORD_REGION, STATUS_COORD_MOBILE, STATUS_CALLER, STATUS_COORD_CALLER = 0, 1, 2, 4, 8, 16, 16384

  #Член ПРГ в резерве, Член ПРГ УИК, Член ПСГ ТИК, Член ПРГ ТИК
  STATUS_PRG_RESERVE, STATUS_PRG, STATUS_TIC_PSG, STATUS_TIC_PRG = 32, 64, 128, 256

  #Член ПСГ УИК, кандидат, доверенное лицо кандидата, журналист освещающий выборы, координатор
  STATUS_PSG, STATUS_CANDIDATE, STATUS_DELEGATE, STATUS_JOURNALIST, STATUS_COORD, STATUS_LAWYER = 512, 1024, 2048, 4096, 8192, 32768

  LEGAL_STATUS_NO, LEGAL_STATUS_YES, LEGAL_STATUS_LAWYER = 0, 1, 3

  validates :data_processing_allowed, acceptance: { :message => "Требуется подтвердить" }

  validates :first_name, :presence => true
  validates :last_name,  :presence => true
  validates :patronymic,  :presence => true
  validates :email, :presence => true, :format => { :with => /.+@.+\..+/i }
  validates :phone, :presence => true
  #validates_format_of :phone, with: /\A\d{10}\z/
  validates :adm_region, :presence => true
  validates :desired_statuses, :presence => true, :exclusion => { :in => [NO_STATUS], :message => "Требуется выбрать хотя бы один вариант" }
  validates :has_car, :inclusion =>  { :in => [true, false], :message => "требуется указать" }
  validates :has_video, :inclusion =>  { :in => [true, false], :message => "требуется указать" }
  validates :legal_status, :inclusion =>  { :in => [LEGAL_STATUS_NO, LEGAL_STATUS_YES, LEGAL_STATUS_LAWYER] }
  validates :experience_count, :presence => true
  validates :experience_count,
            :numericality  => {:only_integer => true, :equal_to => 0, :message => "Если у Вас был опыт, поставьте соответствующие отметки"},
            if: Proc.new { |a| a.previous_statuses == NO_STATUS }
  validates :experience_count,
            :numericality  => {:only_integer => true, :greater_than => 0, :message => "Если у Вас был опыт, то количество раз - как минимум 1"},
            unless: Proc.new { |a| a.previous_statuses == NO_STATUS }

  validates :sex_male, :inclusion =>  { :in => [true, false], :message => "требуется указать" }
  validates :year_born,
            :presence => true,
            :numericality  => {:only_integer => true, :greater_than => 1900, :less_than => 2000,  :message => "Неверный формат"}

  validates :ip, :presence => true
  validates :uic, format: {with: /\A([0-9]+)(,\s*[0-9]+)*\z/}, allow_blank: true

  validate :check_regions

  attr_accessor :verification
  validate :check_phone_verified
  before_create :set_phone_verified_status
  after_create :send_email_confirmation

  state_machine initial: :pending do
    event(:reject) {transition all => :rejected}
  end

  SOCIAL_ACCOUNTS = {vk: "ВКонтакте", fb: "Facebook", twitter: "Twitter", lj: "LiveJournal" , ok: "Одноклассники"}
  SOCIAL_ACCOUNTS.each do |provider_key, provider_name|
    method_n = 'social_'+provider_key.to_s
    define_method(method_n) { social_accounts[provider_key] }
    define_method(method_n+'=') do |val|
      self.social_accounts[provider_key] = val
    end
  end


  def self.all_future_statuses
    {
        STATUS_OBSERVER => "observer",
        STATUS_MOBILE => "mobile",
        STATUS_CALLER => "caller",
        STATUS_COORD_REGION => "coord_region",
        STATUS_COORD_MOBILE => "coord_mobile",
        STATUS_COORD_CALLER => "coord_caller"
        #STATUS_PRG_RESERVE => "prg_reserve"
    }
  end

  def self.future_statuses_methods
    self.all_future_statuses.values.collect{ |v| "can_be_#{v}" }
  end

  def self.all_previous_statuses
    {
        STATUS_OBSERVER => "observer",
        STATUS_MOBILE => "mobile",
        STATUS_PRG => "prg",
        STATUS_PSG => "psg",
        STATUS_TIC_PRG => "tic_prg",
        STATUS_TIC_PSG => "tic_psg",
        STATUS_LAWYER => "lawyer",
        STATUS_CANDIDATE => "candidate",
        STATUS_DELEGATE => "delegate",
        STATUS_JOURNALIST => "journalist",
        STATUS_COORD => "coord"
    }
  end

  def self.previous_statuses_methods
    self.all_previous_statuses.values.collect{ |v| "was_#{v}" }
  end

  def self.social_methods
    SOCIAL_ACCOUNTS.keys.collect{ |v| "social_#{v}" }
  end

  def self.all_statuses
    all_future_statuses.merge(all_previous_statuses).merge(NO_STATUS => "no_status")
  end
  
  def confirm!
    update_attributes confirmed_at: Time.now
  end

  def confirmed?
    confirmed_at ? true : false
  end
  
  def can_be(status_value)
    desired_statuses & status_value == status_value
  end

  def was(status_value)
    previous_statuses & status_value == status_value
  end


  self.all_future_statuses.each do |status_value, status_name|
    method_n = "can_be_#{status_name}"
    define_method(method_n) { can_be status_value }
    define_method("#{method_n}=") do |val|
      if val == "1" || val == true
        self.desired_statuses |= status_value
      else
        self.desired_statuses &= ~status_value
      end
    end
  end

  self.all_previous_statuses.each do |status_value, status_name|
    method_n = "was_#{status_name}"
    define_method(method_n) { was status_value }
    define_method("#{method_n}=") do |val|
      if val == '1' || val == true
        self.previous_statuses |= status_value
      else
        self.previous_statuses &= ~status_value
      end
    end
  end

  def verified?
    verification.present? && verification.confirmed? && verification.phone_number == self.phone
  end

  def send_email_confirmation
    self.confirmation_token = SecureRandom.hex(16)
    save
    ConfirmationMailer.email_confirmation(self).deliver
  end

  private

  def set_phone_verified_status
    self.phone_verified = verified?
  end

  def check_regions
    errors.add(:region, 'Район должен принадлежать выбранному округу') if region && region.parent != adm_region
  end

  def check_phone_verified
    errors.add(:phone, 'не подтвержден') unless verified?
  end
end
