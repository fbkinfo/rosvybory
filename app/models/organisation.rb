class Organisation < ActiveRecord::Base

  has_many :users
  has_many :user_apps

  validates_uniqueness_of :name

end
