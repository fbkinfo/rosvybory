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

  def letter_url(user)
    [:observer, :psg].each do |role|
      return letter_user_path(format: :pdf, report: role) if user.has_role?(role)
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
