class DislocationControl < Uic

  def participant(index)
    participants[index]
  end

  def participants
    @participants ||= begin
      if user_current_roles.present?
        data = user_current_roles.includes(:user, :current_role).order(:id)
        data.sort_by(&:current_role_priority)
      else
        []
      end
    end
  end

end
