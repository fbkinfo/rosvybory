ActiveAdmin.register CallCenter::ViolationType do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 25, if: proc{ can? :crud,  CallCenter::ViolationType }
  actions :index, :show

  config.sort_order = "name_asc"
  config.paginate = false

  index do
    column :name
    column :reports_count do |violation_type|
      CallCenter::Report.joins(violation: :violation_type).where("call_center_violation_types.id = ?", violation_type.id).count
    end
    column :violations_count do |violation_type|
      CallCenter::Violation.joins(:violation_type).where(violation_type_id: violation_type.id).count
    end
  end
end
