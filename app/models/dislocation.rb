# encoding: utf-8

class Dislocation < User

  belongs_to :nomination_source, foreign_key: :user_current_role_nomination_source_id
  belongs_to :current_role, foreign_key: :user_current_role_current_role_id
  belongs_to :uic, foreign_key: :user_current_role_uic_id

  ransacker :current_role_uic do
    Arel::Nodes::SqlLiteral.new("(select number from uics where uics.id = uic_id)")
  end

  ransacker :current_role_adm_region, {:formatter => :to_i.to_proc} do
    Arel::Nodes::SqlLiteral.new("coalesce((select regions.adm_region_id from regions where regions.id = user_current_roles.region_id), users.adm_region_id)")
  end

  ransacker :current_role_region, {:formatter => :to_i.to_proc} do
    Arel::Nodes::SqlLiteral.new("coalesce(user_current_roles.region_id, users.region_id)")
  end

  ransacker :current_role_nomination_source_id do
    Arel::Nodes::SqlLiteral.new("user_current_roles.nomination_source_id")
  end

  ransacker :user_current_role_got_docs do
    Arel::Nodes::SqlLiteral.new('user_current_roles.got_docs')
  end

  # возвращает пользователей и их текущие роли (один пользователь может быть 1 и больше раз)
  # роли, которые не должны отображаться в расстановке игнорируются - если у пользователя только такие роли, то это выглядит так же, как если бы у него не было ни одной
  # каждая строка содержит все поля таблиц users и user_current_roles
  def self.with_current_roles
    @@dislocatable_current_roles ||= CurrentRole.dislocatable.pluck(:id).join(',')
    @@select_fields ||= User.column_names.map(&User.arel_table.method(:[])) +
                        UserCurrentRole.column_names.map {|col| UserCurrentRole.arel_table[col].as("user_current_role_#{col}")}
    joins("left join user_current_roles on user_current_roles.user_id = users.id AND user_current_roles.current_role_id IN (#{@@dislocatable_current_roles})").
      select(@@select_fields)
  end

  def self.with_role(role_slug)
    joins(:user_roles => :role).where(:roles => {:slug => role_slug})
  end


  # DISLOCATION_RULES:
  # Ограничения расстановки, в зависимости от типа источника выдвижения.
  # каждое правило имеет вид:
  #  <тип_источника> => { <ограничения> }
  # ограничения это Hash следующего вида:
  #  <роль_наблюдателя> => <количество>
  #
  # Расстановка некорректна, если количество наблюдателей данного типа от одного источника
  # превысило ограничение для этого типа наблюдателя.
  #
  # Если правило для типа источника не существует — ограничений для этого типа источника нет.
  # Если в правиле для типа источника не указано ограничение для роли наблюдателя — ограничений
  #   для этой роли наблюдателя нет.
  #
  DISLOCATION_RULES = {
    'candidate'  => { 'observer' => 1, 'psg' => 1 },
    'party'      => { 'observer' => 1, 'psg' => 0 },
    'parliament' => { 'observer' => 1, 'psg' => 1 }
  }

  # Контролируемые роли наблюдателя
  CONTROLLED_ROLES_SLUGS = DISLOCATION_RULES.values.map(&:keys).flatten.uniq

  # Проверяет корректность расстановки.
  # Возвращает +Array+ с сообщениями об ошибках, или +nil+ если ошибок не найдено
  #
  # Расстановка некорректна, если хотя бы одно условие выполняется:
  # 1) на этом же участке этот же наблюдатель назначен более одного раза
  #    на роли из набора контролируемых ролей
  # 2) для источника выдвижения и типа наблюдателя нарушаются DISLOCATION_RULES
  #
  def check_dislocation_for_errors
    current_role_id = user_current_role_current_role_id
    # собираем все контролируемые роли
    @@controlled_roles_ids ||= CurrentRole.where( slug: CONTROLLED_ROLES_SLUGS ).pluck(:id)
    unless @@controlled_roles_ids.include? current_role_id
      # текущая роль не входит в проверяемые
      return nil
    end

    # все расстановки на этом же участке с контролируемыми ролями
    uic_ucr = UserCurrentRole.where( uic_id: user_current_role_uic_id, current_role_id: @@controlled_roles_ids )
    errors = nil

    # 1) сколько раз пользователь расставлен на участок
    check_user_count = uic_ucr.where( user_id: id ).count
    if check_user_count > 1
      errors ||= []
      errors << "наблюдатель расставлен на УИК № #{uic.try(:number)} больше одного раза"
    end

    # 2) сколько таких же ролей от того же источника выдвижения
    return nil unless nomination_source.present?
    return nil unless DISLOCATION_RULES[nomination_source.variant].present?
    dislocation_rule_limit = DISLOCATION_RULES[nomination_source.variant][current_role.slug]
    return nil unless dislocation_rule_limit.present?

    check_role_nomination_count = uic_ucr.where(
      current_role_id: current_role_id,
      nomination_source_id: user_current_role_nomination_source_id
    ).count
    if check_role_nomination_count > dislocation_rule_limit
      errors ||= []
      errors << "источник '#{nomination_source.name}' типа '#{nomination_source.human_variant}'"+
        " не может назначить больше #{dislocation_rule_limit} наблюдателей "+
        " в роли '#{current_role.try(:name)}' на УИК № #{uic.try(:number)}."
    end
    errors
  end

  # Уникальный идентификатор расстановки.
  #
  def duid
    "duid_#{id}_#{user_current_role_id}"
  end
end
