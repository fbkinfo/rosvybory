class Dislocation < User

  ransacker :current_role_uic do
    Arel::Nodes::SqlLiteral.new("(select number from uics where uics.id = uic_id)")
  end

  ransacker :current_role_nomination_source_id do
    Arel::Nodes::SqlLiteral.new("user_current_roles.nomination_source_id")
  end

  # возвращает пользователей и их текущие роли (один пользователь может быть 1 и больше раз)
  # каждая строка содержит все поля пользователя + uic_id, current_role_id и nomination_source_id из user_current_roles
  def self.with_current_roles
    @@select_fields ||= User.column_names.map(&User.arel_table.method(:[])) +
                        UserCurrentRole.column_names.map {|col| UserCurrentRole.arel_table[col].as("user_current_role_#{col}")}
    joins("left join user_current_roles on user_current_roles.user_id = users.id").
      select(@@select_fields)
  end

  def self.with_role(role_slug)
    joins(:user_roles => :role).where(:roles => {:slug => role_slug})
  end


  def self.ransackable_attributes(auth_object = nil)
    column_names + ['current_role_uic', 'current_role_nomination_source_id']
  end
end
