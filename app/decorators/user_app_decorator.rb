class UserAppDecorator < Draper::Decorator
  delegate_all

  def current_status
    h.status_human_readable object.current_status
  end

  def desired_statuses
    h.status_human_readable object.desired_statuses
  end

  def legal_status
    h.legal_status_human_readable object.legal_status
  end

  def previous_statuses
    h.status_human_readable object.previous_statuses
  end

  def can_be_coord_region
    object.can_be_coord_region ? "Да":"Нет"
  end

  def has_car
    object.has_car ? "Есть":"Нет"
  end

  def social_accounts
    h.raw h.social_accounts_readable(object.social_accounts)
  end

  def sex_male
    object.sex_male ? "М":"Ж"
  end

  def phone_verified
    object.phone_verified ? "Да":"Нет"
  end

  def phone_formatted
    phonenumber = phone.gsub(/\D/, '')
    if phonenumber.size == 11
      phonenumber[0] = '7' if phonenumber[0] == '8'
    elsif phonenumber.size == 10
      phonenumber = '7' + phonenumber
    end
    if phonenumber.size == 11
      phonenumber = "+#{phonenumber[0]} #{phonenumber[1..3]} #{phonenumber[4..6]}-#{phonenumber[7..8]}-#{phonenumber[9..10]}"
    else
      phone
    end
  end

  def full_name
    [last_name, first_name, patronymic].join ' '
  end
end
