ActiveAdmin.register CallCenter::Operator do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 6, if: proc{ can? :read,  CallCenter::Operator }
  actions :all

  config.sort_order = "last_name_asc"
  config.paginate = false

  index do
    column :id
    column :full_name do |operator|
      [operator.last_name, operator.first_name, operator.patronymic].join " "
    end
    column :phone_calls_count do |operator|
      CallCenter::PhoneCall.joins(:operator).where("call_center_operators.id = ?", operator.id).count
    end
    column :completed_phone_calls_count do |operator|
      CallCenter::PhoneCall.joins(:operator).where("call_center_operators.id = ? AND call_center_phone_calls.status = ?", operator.id, "completed").count
    end
    column :started_phone_calls_count do |operator|
      CallCenter::PhoneCall.joins(:operator).where("call_center_operators.id = ? AND call_center_phone_calls.status = ?", operator.id, "started").count
    end
    column :reports_count do |operator|
      CallCenter::Report.joins(phone_call: :operator).where("call_center_operators.id = ?", operator.id, ).count
    end
    column :violations_count do |operator|
      CallCenter::Violation.joins(report: {phone_call: :operator}).where("call_center_operators.id = ?", operator.id, ).count
    end
    column :last_phone_call do |operator|
      CallCenter::PhoneCall.joins(:operator).where("call_center_operators.id = ?", operator.id).order("created_at DESC").first.try(:created_at)
    end
    default_actions
  end

  form do |f|
    f.inputs :last_name, :first_name, :patronymic
    f.actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end

