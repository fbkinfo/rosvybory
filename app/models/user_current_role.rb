class UserCurrentRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :current_role
  belongs_to :nomination_source
  belongs_to :region
  belongs_to :uic

  validates :current_role, presence: true
  validate :region_or_uic_present

  #attr_accessor :adm_region_id

  private

  def region_or_uic_present
    unless region.present? || uic.present?
      errors.add(:region, "Надо выбрать ТИК или УИК") unless current_role.slug == "reserve"
    end
  end
end
