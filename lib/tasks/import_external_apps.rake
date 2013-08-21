desc "Импорт заявок"
task import_external_apps: :environment do

  # stub
  ENV['SOURCE'] = 'gn'
  ENV['FILE'] = Rails.root.join("docs/external_apps.xls").to_s

  if ENV['SOURCE'].nil?
    raise 'No SOURCE passed. Available options: gn/sonar/golos'
  end

  if ENV['FILE'].nil?
    raise 'No FILE passed'
  end

  importer = ExternalAppsImporter.new(ENV['FILE'], ENV['SOURCE'])
  importer.import
end
