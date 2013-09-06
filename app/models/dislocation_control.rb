class DislocationControl < Uic

  def participant(index)
    participants[index]
  end

  def participants
    @@dislocatable_ids ||= CurrentRole.dislocatable.pluck(:id)
    @participants ||= begin
      if user_current_roles.present?
        data = user_current_roles.where(current_role_id: @@dislocatable_ids).includes(:user, :current_role).order(:id)
        data.sort_by(&:current_role_priority)
      else
        []
      end
    end
  end

end
