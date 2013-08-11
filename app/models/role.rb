class Role < ActiveRecord::Base
  validates_uniqueness_of :name, :short_name, :slug
end
