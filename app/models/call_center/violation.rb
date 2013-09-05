class CallCenter::Violation < ActiveRecord::Base
  belongs_to :violation_type
  has_one :report
end
