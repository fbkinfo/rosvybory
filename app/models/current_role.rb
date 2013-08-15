class CurrentRole < ActiveRecord::Base
  has_many :user_app_current_roles, dependent: :destroy
  has_many :user_apps, through: :user_app_current_roles
end
