class CallCenter::ViolationCategory < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :violation_types
end
