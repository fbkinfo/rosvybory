class CallCenter::Reporter < ActiveRecord::Base
  belongs_to :dislocation, foreign_key: "user_id", class_name: "Dislocation"
  has_one :report
end
