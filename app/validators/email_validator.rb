require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    begin
      address = Mail::Address.new(value)
      tree = address.__send__(:tree)

      result = address.domain && address.address == value
      result &&= (tree.domain.dot_atom_text.elements.size > 1)

    rescue Exception => e
      result = false
    end
    record.errors[attribute] << (options[:message] || I18n.t('.errors.messages.invalid')) unless result
  end
end