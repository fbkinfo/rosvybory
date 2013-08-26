class UserCurrentRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :current_role
  belongs_to :region
  belongs_to :uic

  validates :current_role, presence: true
  validate :region_or_uic_present

  delegate :number, :to => :uic, :prefix => true, :allow_nil => true
  def uic_number=(number)
    self.uic = Uic.find_by_number(number)
  end

  #attr_accessor :adm_region_id

  private

  def region_or_uic_present
    unless region.present? || uic.present?
      errors.add(:region, "Надо выбрать ТИК или УИК") unless current_role.slug == "reserve"
    end
  end
end
