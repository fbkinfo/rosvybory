require 'csv'
desc "Импорт уиков"
task import_uics: :environment do
  #создаем УИКи
  CSV.foreach(Rails.root.join("docs/uics.csv"), headers: true) do |row|
    region_name = row[1].mb_chars.titleize.to_s.sub(/ Ао/, " АО")
    region = Region.where(name: region_name).first!
    puts "%s, %s" % [region_name, row[2]]
    Uic.create kind: Uic.uic_value, region_id: region.id, number: row[2].to_i, is_temporary: !row[3].blank?, has_koib: !row[4].blank?
  end

  #создаем ТИКи
  tics_hash = {} # region_id -> Uic (Tic, i.e.)
  Region.with_tics.find_each do |region|
    tics_hash[region.id] = Uic.where(:kind => Uic.tic_value, :region_id => region.id).first_or_create
  end

  #привязываем УИКи к ТИКам
  Uic.where(:kind => nil).find_each do |uic|
    uic.update_columns :parent_id => tics_hash[uic.region_id].id
  end

end
