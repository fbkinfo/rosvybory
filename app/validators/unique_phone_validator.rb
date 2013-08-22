class UniquePhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if User.where(phone: value).any? || UserApp.without_state(:rejected).where(phone: value).any?
      record.errors[attribute] << (options[:message] || 'используется')
    end
  end
end
