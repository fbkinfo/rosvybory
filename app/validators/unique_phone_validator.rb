class UniquePhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if User.where(phone: value).any? || UserApp.where(phone: value).any?
      record.errors[attribute] << 'используется'
    end
  end
end
