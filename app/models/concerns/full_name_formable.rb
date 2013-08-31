module FullNameFormable

  def first_name=(v)
    write_attribute(:first_name, v)
    update_full_name
  end

  def last_name=(v)
    write_attribute(:last_name, v)
    update_full_name
  end

  def patronymic=(v)
    write_attribute(:patronymic, v)
    update_full_name
  end

  def full_name=(_)
    raise 'FullName is readonly'
  end

  def update_full_name
    write_attribute(:full_name, [self.last_name, self.first_name, self.patronymic].join(' '))
  end

end