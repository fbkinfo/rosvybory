class UserCurrentRole < ActiveRecord::Base
  belongs_to :current_role
  belongs_to :nomination_source
  belongs_to :region
  belongs_to :uic
  belongs_to :user, inverse_of: :user_current_roles

  validates :current_role, presence: true
  validate :region_or_uic_present
  validate :tic_belongs_to_region
  validate :uic_belongs_to_region

  delegate :number, :to => :uic, :prefix => true, :allow_nil => true
  def uic_number=(number)
    self.uic = Uic.find_by_number(number)
  end

  #attr_accessor :adm_region_id

  private

  def region_or_uic_present
    unless region.present? || uic.present? || %w(reserve observer).include?(current_role.slug)
      errors.add(:region, "Надо выбрать ТИК или УИК")
    end
  end

  def tic_belongs_to_region
    return true unless region.present?
    if user.region.present? && user.region != region
      errors.add(:region, "ТИК и район пользователя не совпадают")
    elsif user.adm_region.present? && region.parent.present? && user.adm_region != region.parent
      errors.add(:region, "ТИК и адм.округ пользователя не совпадают")
    end
  end

  def uic_belongs_to_region
    return true unless uic.present?
    if user.region.present? && !uic.belongs_to_region?( user.region )
      errors.add(:uic_number, "Район УИК и район пользователя не совпадают")
    elsif user.adm_region.present? && !uic.belongs_to_region?( user.adm_region )
      errors.add(:uic_number, "Адм.округ УИК и пользователя не совпадают")
    end
  end

end
