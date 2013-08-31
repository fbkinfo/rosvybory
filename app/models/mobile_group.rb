class MobileGroup < ActiveRecord::Base
  belongs_to :adm_region, class_name: "Region"
  belongs_to :organisation
  belongs_to :region

  validates :organisation_id, presence: true
  validates :name, presence: true, uniqueness: true

  delegate :name, :to => :adm_region, :prefix => true, :allow_nil => true
  delegate :name, :to => :organisation, :prefix => true, :allow_nil => true
  delegate :name, :to => :region, :prefix => true, :allow_nil => true
end
