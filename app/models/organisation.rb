class Organisation < ActiveRecord::Base

  has_many :users
  has_many :user_apps

end
