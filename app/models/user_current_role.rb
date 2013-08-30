class UserCurrentRole < ActiveRecord::Base
  belongs_to :current_role
  belongs_to :nomination_source
  belongs_to :region
  belongs_to :uic, :inverse_of => :user_current_roles
  belongs_to :user, inverse_of: :user_current_roles

  validates :current_role, presence: true
  validates :nomination_source, presence: true
  validates_uniqueness_of :current_role_id, :scope => :user_id
  validate :region_or_uic_present
  validate :tic_belongs_to_region
  validate :uic_belongs_to_region
  validate :validate_legitimacy

  delegate :number, :to => :uic, :prefix => true, :allow_nil => true
  def uic_number=(number)
    self.uic = Uic.find_by_number(number)
  end

  delegate :priority, :to => :current_role, :prefix => true

  #attr_accessor :adm_region_id

  private

  def region_or_uic_present
    unless region.present? || uic.present? || %w(reserve observer).include?(current_role.try(:slug))
      errors.add(:region, "Надо выбрать ТИК") if current_role.try(:must_have_tic?)
      errors.add(:uic_number, "Надо выбрать УИК") if current_role.try(:must_have_uic?)
    end
  end

  def tic_belongs_to_region
    return true unless region.present?
    if user.region.present? && user.region != region
      errors.add(:region, "не совпадает с районом пользователя")
    elsif user.adm_region.present? && region.parent.present? && user.adm_region != region.parent
      errors.add(:region, "не совпадает с адм.округом пользователя")
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

  def validate_legitimacy
    return unless current_role.present? && nomination_source.present?
    case current_role.slug
    when 'journalist'
      if nomination_source.variant != 'media'
        errors.add(:nomination_source, :incorrect_nomination_source)
      end
    end
  end
end
