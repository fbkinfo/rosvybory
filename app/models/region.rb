class Region < ActiveRecord::Base

  belongs_to :parent, class_name: 'Region'

  CITY, ADM_REGION, MUN_REGION = 1, 2, 3

  scope :cities, -> { where(kind: CITY) }
  scope :adm_regions, -> { where(kind: ADM_REGION) }

  has_many :regions, -> { order :name }, foreign_key: "parent_id"

end
