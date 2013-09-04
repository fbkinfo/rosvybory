class Region < ActiveRecord::Base
  extend Enumerize
  acts_as_nested_set

  belongs_to :adm_region, class_name: 'Region'  # cached closest adm_region
  belongs_to :parent, class_name: 'Region'
  default_scope -> { order(:name) }

  validates_uniqueness_of :name # TODO maybe :scope => :parent_id ?

  enumerize :kind, in: {city: 1, adm_region: 2, mun_region: 3}, default: :city, scope: true, predicates: true

  scope :cities, -> { with_kind(:city).order :name }
  scope :adm_regions, -> { with_kind(:adm_region) }
  scope :mun_regions, -> { with_kind(:mun_region).order(:name) }
  scope :with_tics, -> { where(has_tic: true) }

  has_many :regions, -> { order :name }, foreign_key: "parent_id"
  has_many :uics, dependent: :destroy

  has_many :subsubregions, :through => :regions, :source => :regions

  before_save :cache_adm_region_id

  def self.mun_region_value; 3; end

  def subregions_with_tics
    if has_tic?
      Region.where(id: id)  # self?
    else
      regions.with_tics
    end
  end

  def uics_with_nested_regions
    Uic.where(:region_id => self_and_descendants.except(:order))
  end

  def to_s
    name
  end

  private
    def cache_adm_region_id
      self.adm_region = adm_region?? self : parent.try(:adm_region)
    end
end
