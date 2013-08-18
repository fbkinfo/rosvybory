require 'csv'
desc "Импорт уиков"
task import_uics: :environment do
  CSV.foreach(Rails.root.join("docs/uics.csv"), headers: true) do |row|
    region_name = row[1].mb_chars.titleize.to_s.sub(/ Ао/, " АО")
    region = Region.where(name: region_name).first!
    puts "%s, %s" % [region_name, row[2]]
    Uic.create! region_id: region.id, number: row[2].to_i, is_temporary: !row[3].blank?, has_koib: !row[4].blank?
  end
end
