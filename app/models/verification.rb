class Verification < ActiveRecord::Base
  validates :phone_number, presence: true

  scope :confirmed, -> { where(confirmed: true) }

  after_initialize do
    self[:code] ||= (100000 + rand(899999)).to_s
  end

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
end
