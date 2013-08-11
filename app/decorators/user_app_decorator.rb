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
end
