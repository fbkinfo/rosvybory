class UserApp < ActiveRecord::Base
  serialize :social_accounts, HashWithIndifferentAccess
  belongs_to :region
  belongs_to :adm_region, class_name: "Region"

  before_save :set_adm_region

  #наблюдатель, участник мобильной группы, территориальный координатор, координатор мобильной группы, оператор горячей линии
  NO_STATUS, STATUS_OBSERVER, STATUS_MOBILE, STATUS_COORD_REGION, STATUS_COORD_MOBILE, STATUS_CALLER = 0, 1, 2, 4, 8, 16

  #Член ПРГ в резерве, Член ПРГ УИК, Член ПСГ ТИК, Член ПРГ ТИК
  STATUS_PRG_RESERVE, STATUS_PRG, STATUS_TIC_PSG, STATUS_TIC_PRG = 32, 64, 128, 256

  #Член ПСГ УИК, кандидат, доверенное лицо кандидата, журналист освещающий выборы, координатор
  STATUS_PSG, STATUS_CANDIDATE, STATUS_DELEGATE, STATUS_JOURNALIST, STATUS_COORD = 512, 1024, 2048, 4096, 8192

  LEGAL_STATUS_NO, LEGAL_STATUS_YES, LEGAL_STATUS_LAWYER = 0, 1, 3

  validates :data_processing_allowed, acceptance: { :message => "Требуется подтвердить" }

  validates :first_name, :presence => true
  validates :last_name,  :presence => true
  validates :patronymic,  :presence => true
  validates :email, :presence => true, :format => { :with => /.+@.+\..+/i }
  validates :phone, :presence => true
  #validates :region, :presence => true
  validates :desired_statuses, :presence => true, :exclusion => { :in => [NO_STATUS], :message => "Требуется выбрать хотя бы один вариант" }
  validates :current_status, :presence => true
  validates :has_car, :inclusion =>  { :in => [true, false], :message => "требуется указать" }
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

  def full_name
    [last_name, first_name, patronymic].join ' '
  end

  def phone_formatted
    phonenumber = phone.gsub(/\D/, '')
    if phonenumber.size == 11
      phonenumber[0] = '7' if phonenumber[0] == '8'
    elsif phonenumber.size == 10
      phonenumber = '7' + phonenumber
    end
    if phonenumber.size == 11
      phonenumber = "+#{phonenumber[0]} #{phonenumber[1..3]} #{phonenumber[4..6]}-#{phonenumber[7..8]}-#{phonenumber[9..10]}"
    else
      phone
    end
  end

  def set_adm_region
    self.adm_region = region.try(:parent)
  end

  SOCIAL_ACCOUNTS = {vk: "ВКонтакте", fb: "Facebook", twitter: "Twitter", lj: "LiveJournal" , ok: "Одноклассники"}
  SOCIAL_ACCOUNTS.each do |provider_key, provider_name|
    method_n = 'social_'+provider_key.to_s
    define_method(method_n) { social_accounts[provider_key] }
    define_method(method_n+'=') do |val|
      self.social_accounts[provider_key]=val
    end
  end


  def self.all_future_statuses
    {
        STATUS_OBSERVER => "observer",
        STATUS_MOBILE => "mobile",
        STATUS_COORD_REGION => "coord_region",
        STATUS_COORD_MOBILE => "coord_mobile",
        STATUS_CALLER => "caller"
        #STATUS_PRG_RESERVE => "prg_reserve"
    }
  end

  def self.future_statuses_methods
    self.all_future_statuses.values.collect{|v| "can_be_"+v}
  end

  def self.all_previous_statuses
    {
        STATUS_OBSERVER => "observer",
        STATUS_MOBILE => "mobile",
        STATUS_PRG => "prg",
        STATUS_PSG => "psg",
        STATUS_TIC_PRG => "tic_prg",
        STATUS_TIC_PSG => "tic_psg",
        STATUS_CANDIDATE => "candidate",
        STATUS_DELEGATE => "delegate",
        STATUS_JOURNALIST => "journalist",
        STATUS_COORD => "coord"
    }
  end

  def self.previous_statuses_methods
    self.all_previous_statuses.values.collect{|v| "was_"+v}
  end

  def self.all_current_statuses
    {
        STATUS_PRG_RESERVE => "prg_reserve",
        STATUS_PRG => "prg",
        STATUS_TIC_PSG => "tic_psg",
        STATUS_TIC_PRG => "tic_prg"
    }
  end

  def self.social_methods
    SOCIAL_ACCOUNTS.keys.collect{|v| "social_"+v.to_s}
  end

  def self.all_statuses
    all_future_statuses.merge(all_previous_statuses).merge(all_current_statuses).merge(NO_STATUS => "no_status")
  end

  def can_be(status_value)
    desired_statuses & status_value > 0
  end

  def was(status_value)
    previous_statuses & status_value > 0
  end


  self.all_future_statuses.each do |status_value, status_name|
    method_n = 'can_be_'+status_name
    define_method(method_n) { can_be status_value }
    define_method(method_n+'=') do |val|
      if val == "1" || val == true
        self.desired_statuses |= status_value
      else
        self.desired_statuses &= ~status_value
      end
    end
  end

  self.all_previous_statuses.each do |status_value, status_name|
    method_n = 'was_'+status_name
    define_method(method_n) { was status_value }
    define_method(method_n+'=') do |val|
      if val == "1" || val == true
        self.previous_statuses |= status_value
      else
        self.previous_statuses &= ~status_value
      end
    end
  end


end
