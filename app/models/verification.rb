class Verification < ActiveRecord::Base
  validates :phone_number, presence: true, format: { with: /\A\d{10}\z/ }

  scope :confirmed, -> { where(confirmed: true) }

  after_initialize do
    self[:code] ||= (100000 + rand(899999)).to_s
  end

  before_validation :normalize_phone_number
  after_create :send_sms

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
    self.phone_number = phone_number.gsub /[^\d+]/, '' unless phone_number.blank?
  end
end
