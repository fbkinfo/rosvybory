class CallCenter::ViolationType < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  belongs_to :violation_category
end
