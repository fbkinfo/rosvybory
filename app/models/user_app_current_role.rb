class UserAppCurrentRole < ActiveRecord::Base
  belongs_to :user_app
  belongs_to :current_role
  validates :user_app_id, :current_role_id, presence: true
end
