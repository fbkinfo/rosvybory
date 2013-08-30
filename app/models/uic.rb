class Uic < ActiveRecord::Base
  belongs_to :region
  validates :region_id, :number, presence: true
  validates_uniqueness_of :number

  has_many :user_current_roles, :inverse_of => :uic

  # Returns +true+ if Uic belongs to +other_region+
  # which is a Region object of any kind (:city, :adm_region, :mun_region)
  #
  def belongs_to_region?(other_region)
    region.present? && (
      region == other_region ||
      region.try(:parent) == other_region ||
      region.try(:parent).try(:parent) == other_region
    )
  end
end
