class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :role

  validates :role_id, presence: true

  delegate :name, :to => :role, :prefix => true, :allow_nil => true
end
