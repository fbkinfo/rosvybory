class CallCenter::ViolationType < ActiveRecord::Base
  belongs_to :violation_category
end
