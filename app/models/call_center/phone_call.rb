class CallCenter::PhoneCall < ActiveRecord::Base
  belongs_to :report
  belongs_to :operator

  VALUES_FOR_STATUS = ["started", "dropped", "completed"]
end
