class CurrentRole < ActiveRecord::Base
  KNOWN_VARIANTS = %w(
    journalist
    observer
    prg
    prg_tic
    psg
    psg_tic
    reserve
  )

  PRIORITY = {
    'prg_tic'    => 1,
    'prg'        => 2,
    'psg_tic'    => 3,
    'psg'        => 4,
    'observer'   => 5,
    'journalist' => 6,
    'reserve'    => 7,
  }

  has_many :user_app_current_roles, dependent: :destroy
  has_many :user_apps, through: :user_app_current_roles

  validates :slug, presence: true, inclusion: {in: KNOWN_VARIANTS}

  default_scope -> { order(CurrentRole.arel_table[:position].asc) }

  scope :dislocatable, -> { where.not(:slug => :reserve) }

  def must_have_tic?
    ['psg_tic', 'prg_tic'].include? slug
  end

  def must_have_uic?
    ['psg', 'prg'].include? slug
  end

  def priority
    PRIORITY[slug]
  end
end
