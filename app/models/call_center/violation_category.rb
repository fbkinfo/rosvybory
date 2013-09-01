class CallCenter::ViolationCategory < ActiveRecord::Base
  has_many :violation_types
end
