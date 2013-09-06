module ApplicationHelper
  def full_name_of(model)
    [:last_name, :first_name, :patronymic].map{|field| model.send(field)}.join " "
  end
end
