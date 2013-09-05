class Role < ActiveRecord::Base
  validates_uniqueness_of :name, :short_name, :slug

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  scope :common, -> { where.not(:slug => ['admin', 'db_operator']) }

end
