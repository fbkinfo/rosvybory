desc "Импорт заявок"
task import_external_apps: :environment do

  # stub
  # ENV['SOURCE'] = 'gn'
  # ENV['FILE'] ||= Rails.root.join("docs/external_apps.xls").to_s

  if ENV['FILE'].nil?
    raise 'No FILE passed'
  end

  importer = ExternalAppsImporter.new(ENV['FILE']) #с такими параметрами не будет обновлять существующих пользователей
  importer.organisation = Organisation.where(name: ENV['SOURCE']).first || raise("No valid SOURCE passed. Available options: #{Organisation.pluck(:name).join(', ')}")
  importer.import
end
