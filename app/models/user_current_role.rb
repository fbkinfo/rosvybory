class UserCurrentRole < ActiveRecord::Base
  belongs_to :current_role
  belongs_to :nomination_source
  belongs_to :region    # a.k.a adm_region_id
  belongs_to :uic, :inverse_of => :user_current_roles
  belongs_to :user, inverse_of: :user_current_roles

  validates :current_role, :nomination_source, presence: true
  validates_uniqueness_of :current_role_id, :scope => :user_id
  validate :validate_legitimacy
  validate :validate_tic_uic

  delegate :number, :to => :uic, :prefix => true, :allow_nil => true

  def uic_number=(number)
    self.uic = number.presence && Uic.find_by_number(number)
  end

  delegate :priority, :to => :current_role, :prefix => true

  def coalesced_region
    @coalesced_region ||= region || user.try(:region) || user.try(:adm_region)
  end

  # it's better to move it to UserCurrentRole decorator
  def selectable_uics
    reg = coalesced_region
    return [] unless reg
    uics = reg.uics_with_nested_regions.order(:name)
    if current_role.try(:must_have_tic?)
      uics.tics
    elsif current_role.try(:must_have_uic?)
      uics.uics
    else
      uics
    end
  end

  private

  def validate_tic_uic
    return unless current_role.present?
    errors.add(:uic, :required) if current_role.must_have_tic? && !uic.try(:tic?)
    errors.add(:uic, :required) if current_role.must_have_uic? && !uic.try(:uic?)
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
