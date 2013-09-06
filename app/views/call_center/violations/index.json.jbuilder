json.updated_at violations.last.try(:created_at) || DateTime.now
json.violations violations do |violation|
  uic = violation.report.reporter.uic rescue nil
  json.id = violation.id
  json.violation_type_id violation.violation_type.try(:id)
  json.uic uic.try(:name)
  json.uic_id uic.try(:id)
  json.text violation.report.try(:text)
  json.created_at violation.created_at
end

json.violation_types CallCenter::ViolationType.select(:id, :name, :violation_category_id), :id, :name, :violation_category_id
json.violation_categories CallCenter::ViolationCategory.select(:id, :name), :id, :name

json.regions Region.select(:id, :kind, :name, :adm_region_id, :parent_id), :id, :kind, :name, :adm_region_id, :parent_id
json.uics Uic.select(:id, :kind, :name, :number, :parent_id, :region_id), :id, :kind, :name, :number, :parent_id, :region_id
