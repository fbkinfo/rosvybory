class CallCenter::Violation < ActiveRecord::Base
  belongs_to :violation_type
end
