class Dislocation < User

  ransacker :current_role_uic do
    Arel::Nodes::SqlLiteral.new("(select number from uics where uics.id = uic_id)")
  end

  ransacker :current_role_nomination_source_id do
    Arel::Nodes::SqlLiteral.new("nomination_source_id")
  end

  ransacker :got_docs do
    UserCurrentRole.arel_table[:got_docs]
  end

  # возвращает пользователей и их текущие роли (один пользователь может быть 1 и больше раз)
  # каждая строка содержит все поля пользователя + uic_id, current_role_id и nomination_source_id из user_current_roles
  def self.with_current_roles
    joins("left join user_current_roles on user_current_roles.user_id = users.id").
      select(
        "users.*, uic_id as current_role_uic_id, "+
        "current_role_id as current_role_id, "+
        "nomination_source_id as current_role_nomination_source_id, "+
        "got_docs"
      )
  end

  def self.with_role(role_slug)
    joins(:user_roles => :role).where(:roles => {:slug => role_slug})
  end


  def self.ransackable_attributes(auth_object = nil)
    column_names + ["current_role_uic", 'current_role_nomination_source_id', 'got_docs']
  end
end
