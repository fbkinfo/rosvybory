class CallCenter::PhoneCall < ActiveRecord::Base
  belongs_to :report

  VALUES_FOR_STATUS = ["started", "dropped", "completed"]
end
