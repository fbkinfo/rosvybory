ActiveAdmin.register CallCenter::Reporter do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 5, if: proc{ can? :read,  CallCenter::Reporter }

  scope "Зарегистрированные" do |items|
    items.where "user_id IS NOT NULL"
  end
  scope "Незарегистрированные" do |items|
    items.where user_id: nil
  end

  index do
    column :known do |reporter|
      reporter.dislocation.present? ? "Да" : "Нет"
    end
    column :full_name do |reporter|
      if reporter.dislocation.present?
        link_to reporter.dislocation.full_name, control_dislocation_path(reporter.dislocation)
      else
        [reporter.last_name, reporter.first_name, reporter.patronymic].join " "
      end
    end
    column :phone
  end
end
