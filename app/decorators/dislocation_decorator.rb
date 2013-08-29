class DislocationDecorator < UserDecorator
  # primary key - user_current_role.id for existing dislocations, user.id for new
  def pk
    user_current_role_id || id
  end
end
