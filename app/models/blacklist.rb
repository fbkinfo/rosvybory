class Blacklist < ActiveRecord::Base
  validates :phone, presence: true
end
