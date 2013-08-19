class Uic < ActiveRecord::Base
  belongs_to :region
  validates :region_id, :number, presence: true
  validates_uniqueness_of :number
end
