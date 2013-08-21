require 'roo'
desc "Импорт заявок"
task import_apps: :environment do

  #ENV-переменную SOURCE (с вариантами gn/sonar/golos)

  #Rails.logger= #volotenter_import-(timestamp).log
  Importer.import Rails.root.join("docs/test_gn.xls").to_s
end
