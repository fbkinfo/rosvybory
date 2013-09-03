module UsersHelper

  def user_current_role_human_readable(ucr)
    ret = ucr.current_role.name.dup
    ret << ": "
    ret << ucr.uic.number.to_s if ucr.uic
    ret << " "
    ret << ucr.region.name if ucr.region
    ret
  end

  def address(user)
    addr = user.address.to_s.strip
    addr.length > 0 ? addr : 'ACHTUNG!!!! ACHTUNG!!!! ACHTUNG!!!! Укажите адрес прописки!'
  end

  def uic(user, slug)
    current_role = CurrentRole.where(slug: slug).first!
    user_current_role = user.user_current_roles.where(current_role: current_role).first
    return user_current_role.uic if user_current_role && user_current_role.uic
  end

  def can_print_letter?(user, status)
    slug = UserApp.all_statuses[status]
    user.current_roles.find { |e| e.slug == slug }
  end

  def optional_string_info(val, placeholder_length = 44)
    v = val.to_s.strip
    v.length > 0 ? v : (1..placeholder_length).map { '_' }.join
  end

  def letter_url(user)
    if [UserApp::STATUS_OBSERVER, UserApp::STATUS_PSG].select { |status| can_print_letter? user, status }.any?
      letter_user_path(format: :pdf)
    else
      nil
    end
  end

  def living(user)
    case user.user_app.try(:sex_male)
      when true
        'проживающий'
      when false
        'проживающая'
      else
        'проживающий(ая)'
    end
  end
end
