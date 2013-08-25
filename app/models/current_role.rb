class CurrentRole < ActiveRecord::Base
  has_many :user_app_current_roles, dependent: :destroy
  has_many :user_apps, through: :user_app_current_roles


  def must_have_tic?
    ["psg_tic", "prg_tic"].include? slug
  end

  def must_have_uic?
    ["psg", "prg"].include? slug
  end

end
