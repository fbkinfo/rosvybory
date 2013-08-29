class Dislocation < User

  # slug ролей, которые учитываются при проверке корректности расстановки
  CHECK_DISLOCATION_CURRENT_ROLES = [ 'observer', 'psg' ]

  ransacker :current_role_uic do
    Arel::Nodes::SqlLiteral.new("(select number from uics where uics.id = uic_id)")
  end

  ransacker :current_role_nomination_source_id do
    Arel::Nodes::SqlLiteral.new("user_current_roles.nomination_source_id")
  end

  ransacker :got_docs do
    UserCurrentRole.arel_table[:got_docs]
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
    column_names + ["current_role_uic", 'current_role_nomination_source_id', 'got_docs']
  end


  # Проверяет корректность расстановки.
  # Возвращает +Array+ с сообщениями об ошибках, или +nil+ если ошибок не найдено
  #
  # Расстановка некорректна, если хотя бы одно условие выполняется:
  # 1) на этом же участке этот же наблюдатель назначен более одного раза
  # 2) на этом же участке, в этой же роли, от того же источника, расставлено более одного наблюдателя
  #
  def check_dislocation_for_errors
    check_current_role_ids = CurrentRole.where( slug: CHECK_DISLOCATION_CURRENT_ROLES ).pluck(:id)
    unless check_current_role_ids.include? current_role_id
      # текущая роль не входит в проверяемые
      return nil
    end

    # все расстановки на этом же участке с ролями из CHECK_DISLOCATION_CURRENT_ROLES
    uic_ucr = UserCurrentRole.where( uic_id: current_role_uic_id, current_role_id: check_current_role_ids )
    errors = nil

    # 1) сколько раз пользователь расставлен на участок
    check_user_count = uic_ucr.where( user_id: id ).count
    if check_user_count > 1
      uic_number = Uic.find( current_role_uic_id ).try(:number)
      errors ||= []
      errors << "наблюдатель расставлен на УИК № #{uic_number} больше одного раза"
    end

    # 2) сколько таких же ролей от того же источника выдвижения
    check_role_nomination_count = uic_ucr.where(
      current_role_id: current_role_id,
      nomination_source_id: current_role_nomination_source_id
    ).count
    if check_role_nomination_count > 1
      current_role_name = CurrentRole.find( current_role_id ).try(:name)
      nomination_source_name = NominationSource.find( current_role_nomination_source_id ).try(:name)
      errors ||= []
      errors << "на УИК № #{uic_number} расставлено больше одного '#{current_role_name}' от источника '#{nomination_source_name}'"
    end
    errors
  end

  # Уникальный идентификатор расстановки.
  #
  def duid
    "duid_#{id}_#{current_role_uic_id}_#{current_role_id}_#{current_role_nomination_source_id}"
  end
end
