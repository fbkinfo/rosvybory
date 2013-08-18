class Region < ActiveRecord::Base
  extend Enumerize

  belongs_to :parent, class_name: 'Region'
  validates_uniqueness_of :name

  enumerize :kind, in: {city: 1, adm_region: 2, mun_region: 3}, default: :city, scope: true

  scope :cities, -> { with_kind(:city).order :name }
  scope :adm_regions, -> { with_kind(:adm_region) }
  scope :mun_regions, -> { with_kind(:mun_region).order(:name) }
  scope :with_tics, -> { where(has_tic: true) }

  has_many :regions, -> { order :name }, foreign_key: "parent_id"
  has_many :uics, dependent: :destroy

  def subregions_with_tics
    if has_tic?
      Region.where(id: id)
    else
      regions.with_tics
    end
  end
end
