class CallCenter::Operator < User
  has_many :phone_calls, foreign_key: "user_id"
  has_many :reports, through: :phone_calls

  default_scope joins(:roles).where(roles: {slug: "callcenter"})
end

