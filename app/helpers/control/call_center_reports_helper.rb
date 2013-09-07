module Control::CallCenterReportsHelper
  def approved_value_text(value)
    value == true ? "Одобрено" : value == false ? "Отклонено" : "Проверить"
  end
end