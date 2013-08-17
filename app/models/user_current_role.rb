class UserCurrentRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :current_role
  belongs_to :region

  validates :current_role, :user, :region, presence: true
end
