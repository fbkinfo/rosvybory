class UserDecorator < Draper::Decorator
  delegate_all

  def user_current_roles
    ucrs = []
    object.user_current_roles.each do |ucr|
      ucrs << h.user_current_role_human_readable(ucr)
    end
    ucrs.join("; ")
  end

end
