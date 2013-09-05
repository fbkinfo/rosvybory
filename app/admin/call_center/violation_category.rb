ActiveAdmin.register CallCenter::ViolationCategory do
  menu parent: I18n.t('active_admin.menu.call_center'), priority: 24, if: proc{ can? :read,  CallCenter::ViolationCategory }
  actions :index, :show

  config.sort_order = "name_asc"
  config.paginate = false

  index do
    column :name
    column :reports_count do |violation_category|
      CallCenter::Report.joins(violation: {violation_type: :violation_category}).where("call_center_violation_categories.id = ?", violation_category.id).count
    end
    # column :violations_count do |violation_type|
    #   CallCenter::Violation.joins(:violation_type).where(violation_type_id: violation_type.id).count
    # end
  end
end
