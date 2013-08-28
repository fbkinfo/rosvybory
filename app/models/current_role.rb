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

  has_many :user_app_current_roles, dependent: :destroy
  has_many :user_apps, through: :user_app_current_roles

  validates :slug, presence: true, inclusion: {in: KNOWN_VARIANTS}

  default_scope -> { order(CurrentRole.arel_table[:position].asc) }

  def must_have_tic?
    ['psg_tic', 'prg_tic'].include? slug
  end

  def must_have_uic?
    ['psg', 'prg'].include? slug
  end

end
