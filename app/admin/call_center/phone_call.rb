ActiveAdmin.register CallCenter::PhoneCall do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 4, if: proc{ can? :read,  CallCenter::PhoneCall }

  actions :index, :show

  scope "Не завершенные" do |items|
    items.where status: "started"
  end
  scope "Завершенные" do |items|
    items.where status: "completed"
  end

  index do
    column :id
    column :status
    column :uic do |phone_call|
      if phone_call.report.present?
        link_to phone_call.report.reporter.uic.name, control_uic_path(phone_call.report.reporter.uic) if phone_call.report.reporter.uic.present?
      end
    end
    column :reporter do |phone_call|
      if phone_call.report.present?
        reporter = phone_call.report.reporter
        if reporter.dislocation.present?
          link_to reporter.dislocation.full_name, control_dislocation_path(reporter.dislocation)
        else
          [reporter.last_name, reporter.first_name, reporter.patronymic].join " "
        end
      end
    end
    column :text do |phone_call|
      phone_call.report.text if phone_call.report.present?
    end
    column :operator do |phone_call|
      phone_call.operator.try(:full_name)
    end
    default_actions
  end

end
