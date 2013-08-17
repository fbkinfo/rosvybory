class Region < ActiveRecord::Base
  extend Enumerize

  belongs_to :parent, class_name: 'Region'
  validates_uniqueness_of :name

  enumerize :kind, in: {city: 1, adm_region: 2, mun_region: 3}, default: :city

  scope :cities, -> { where(kind: CITY).order :name }
  scope :adm_regions, -> { where(kind: ADM_REGION)}
  scope :mun_regions, -> { where(kind: MUN_REGION).order :name }
  scope :with_tics, -> { where(has_tic: true) }

  has_many :regions, -> { order :name }, foreign_key: "parent_id"


  def subregions_with_tics
    if has_tic?
      Region.where(id: id)
    else
      regions.with_tics
    end
  end

end
