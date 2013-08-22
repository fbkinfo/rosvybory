class UserAppDecorator < Draper::Decorator
  delegate_all

  def human_current_roles
    object.current_roles.pluck(:name, :value).map {|r| r.join(": ")}.join("; ")
  end

  def human_desired_statuses
    h.status_human_readable object.desired_statuses
  end

  def human_legal_status
    h.legal_status_human_readable object.legal_status
  end

  def human_previous_statuses
    h.status_human_readable object.previous_statuses
  end

  UserApp.all_future_statuses.each do |status_value, status_name|
    define_method("can_be_#{status_name}") { yes_no (object.can_be status_value) }
  end

  UserApp.all_previous_statuses.each do |status_value, status_name|
    define_method("was_#{status_name}") { yes_no (object.was status_value) }
  end

  def human_has_car
    object.has_car ? "Есть":"Нет"
  end

  def human_has_video
    yes_no object.has_video
  end

  def human_social_accounts
    h.raw h.social_accounts_readable(object.social_accounts)
  end

  def human_sex_male
    object.sex_male ? "М":"Ж"
  end

  def human_phone_verified
    yes_no object.phone_verified
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

  private
    def yes_no(value)
      value ? "Да":"Нет"
    end

end
