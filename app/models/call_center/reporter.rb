class CallCenter::Reporter < ActiveRecord::Base
  has_one :report
  belongs_to :dislocation, foreign_key: "user_id", class_name: "Dislocation"
  belongs_to :current_role
  belongs_to :uic
end
