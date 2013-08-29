class Organisation < ActiveRecord::Base

  has_many :mobile_groups, :dependent => :destroy
  has_many :users
  has_many :user_apps

  validates_uniqueness_of :name

  def to_s
    name
  end
end
