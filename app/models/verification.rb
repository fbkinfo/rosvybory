class Verification < ActiveRecord::Base
  validates :phone_number, presence: true, format: { with: /\A\d{10}\z/ }, unique_phone: { :message => "уже был указан в другой заявке" }

  scope :confirmed, -> { where(confirmed: true) }

  after_initialize do
    self[:code] ||= (100000 + SecureRandom.random_number(899999)).to_s
  end

  before_validation :normalize_phone_number
  after_create :send_sms

  def self.normalize_phone_number(phone_number)
     if phone_number.present?
       phone_number.to_s.split('.')[0].gsub(/\D/, '').last(10)
     end
  end

  def send_sms
    SmsService.send_message(phone_number, "Код подтверждения: #{code}")
  end

  def confirm!(code)
    if self.code == code
      self.update_attribute :confirmed, true
      true
    else
      false
    end
  end

  def normalize_phone_number
    self.phone_number = self.class.normalize_phone_number(phone_number) unless phone_number.blank?
  end
end
