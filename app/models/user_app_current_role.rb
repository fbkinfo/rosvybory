class UserAppCurrentRole < ActiveRecord::Base
  belongs_to :user_app
  belongs_to :current_role
  validates :current_role_id, presence: true
  validate :check_keep

  def keep
    @keep
  end

  def keep=(value)
    @keep = (value == "1")
  end

  private
    def check_keep
      errors.add :base, "#{current_role_id} Не отмечен для сохранения" unless keep
    end
end
