class DislocationControl < Uic

  ransacker :attackers do
    Arel::Nodes::SqlLiteral.new("(select count(1) from user_current_roles where user_current_roles.uic_id = uics.id)")
  end

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

  def participants_count
    participants.size
  end
end
