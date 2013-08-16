class Region < ActiveRecord::Base

  belongs_to :parent, class_name: 'Region'
  validates_uniqueness_of :name

  CITY, ADM_REGION, MUN_REGION = 1, 2, 3

  scope :cities, -> { where(kind: CITY).order :name }
  scope :adm_regions, -> { where(kind: ADM_REGION)}
  scope :mun_regions, -> { where(kind: MUN_REGION).order :name }
  scope :with_tics, -> { where(:has_tic => true) }

  has_many :regions, -> { order :name }, foreign_key: "parent_id"


  def subregions_with_tics
    if has_tic?
      Region.where(id: id)
    else
      regions.with_tics
    end
  end

end
