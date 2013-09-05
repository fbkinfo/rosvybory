class CallCenter::PhoneCall < ActiveRecord::Base
  belongs_to :report
  belongs_to :operator, class_name: "User", foreign_key: "user_id"

  VALUES_FOR_STATUS = ["started", "dropped", "completed"]
end
