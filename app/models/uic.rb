class Uic < ActiveRecord::Base
  extend Enumerize
  include AdmRegionDelegation

  belongs_to :parent, :class_name => 'Uic'
  belongs_to :region

  has_many :children, :class_name => 'Uic', :foreign_key => :parent_id, :dependent => :restrict_with_exception # destroy?
  has_many :user_current_roles, :inverse_of => :uic

  enumerize :kind, in: {tic: 1, uic: 2}, default: :uic, scope: true, predicates: true

  delegate :name, :to => :adm_region, :prefix => true, :allow_nil => true
  delegate :name, :to => :region, :prefix => true, :allow_nil => true

  validates :region_id, presence: true
  validates :number, presence: true, uniqueness: true, :if => :uic?

  before_save :cache_name

  # TODO по идее это должно быть можно получить из enumirize'а ?
  class <<self
    def tic_value; 1; end
    def uic_value; 2; end
    def tics; where(:kind => tic_value); end
    def uics; where(:kind => uic_value); end

    def human_kind(kind)
      {'tic' => 'ТИК', 'uic' => 'УИК'}[kind]
    end
  end

  def as_json(options)
    { id: id, text: full_name }
  end

  # Returns +true+ if Uic belongs to +other_region+
  # which is a Region object of any kind (:city, :adm_region, :mun_region)
  def belongs_to_region?(other_region)
    other_region.is_or_is_ancestor_of? region
  end

  def human_kind
    self.class.human_kind(kind)
  end

  def update_participants_count!
    update_column :participants_count, user_current_roles.joins(:current_role).merge(CurrentRole.dislocatable).count
  end

  private
    def cache_name
      self.name = "#{human_kind} #{uic?? number : region.try(:name)}"
    end

end
