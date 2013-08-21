# При импорте сторонней базы необходимо указывать источник (НО) из следующих значений: ГН ("Гражданин Наблюдатель"), Сонар, Голос.
# Пользователи однозначно идентифицируются по номеру мобильного телефона, существующий пользователь обновляется импортируемыми данными. НО пользователя тоже обновляется наряду с другими данными (да, это может привести к переходу пользователя из одного НО в другой).
# Импортируемые телефон и почта автоматически считаются верифицированными.
# В импортируемых таблицах могут быть пустые ячейки (например, у кого-то может не быть отчества).
# Из столбца "Компетенции" необходимо рассматривать только значения "ЮР" и "АС", т.к. других компетенций у нас пока не заведено.
# Утилита должна выводить для каждой строки, которую не удалось распознать/сохранить, номер строки и хоть какое-то описание причины проблем (понадобится впоследствии, когда будем наворачивать на утилиту web-интерфейс).

require 'roo'
class ExternalAppsImporter
  COLUMNS = {
    uid: 0,           #нет прямого поля
    created_at: 1,
    adm_region: 2,
    region: 3,
    last_name: 4,
    first_name: 5,
    patronymic: 6,
    phone: 7,
    email: 8,

    current_statuses: 10,
    experience_count: 11,
    previous_statuses: 12,
    can_be_reserv: 13,   #нет прямого поля
    can_be_coord_region: 14, #нет прямого поля

    has_car: 15,
    social_accounts: 16,
    extra: 17
  }.freeze

  def initialize(file, source_type)
    @file = file
    @source_type = source_type
  end

  def import
    spreadsheet = open_spreadsheet(@file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      create_user_from_row(row)
    end
  end

  private

  def create_user_from_row(row)
    phone = row[COLUMNS[:phone]]
    region = Region.find_by!(name: row[COLUMNS[:region]])

    adm_region_name = normalize_adm_region(row[COLUMNS[:adm_region]])
    adm_region = Region.adm_regions.find_by!(name: adm_region_name)

    user_app = UserApp.find_or_initialize_by(phone: phone)
    user_app.tap do |a|
      a.email = row[COLUMNS[:email]]
      a.first_name = row[COLUMNS[:first_name]]
      a.last_name = row[COLUMNS[:last_name]]
      a.patronymic = row[COLUMNS[:patronymic]]

      a.region = region
      a.adm_region = adm_region

      a.social_accounts = row[COLUMNS[:social_accounts]]
      a.extra = row[COLUMNS[:extra]]

      a.phone_verified = true
      a.state = :approved

      a.has_car = row[COLUMNS[:has_car]] == "1"
    end
    user_app.confirm!
    user_app.save!

    user = User.create! do |u|
      u.email = row[COLUMNS[:email]]
      u.phone = phone
      u.region = region
      u.user_app = user_app
    end

  end

  def open_spreadsheet(file_path)
    case File.extname(file_path)
      when '.csv' then Roo::Csv.new(file_path, nil, :ignore)
      when '.xls' then Roo::Excel.new(file_path, nil, :ignore)
      when '.xlsx' then Roo::Excelx.new(file_path, nil, :ignore)
      else raise "Unknown file type: #{file_path}"
    end

  end

  def logger
    @logger ||= begin
      stamp = Time.now.stftime("%d_%m_%Y_%H_%M")
      Logger.new(Rails.root.join("log/#{stamp}.log"))
    end
  end

  def normalize_adm_region(name)
    downcased = name.mb_chars.downcase
    case downcased
    when "цао"
      "Центральный АО"
    when "юао"
      "Южный АО"
    when "сао"
      "Северный АО"
    when "свао"
      "Северо-Восточный АО"
    when "вао"
      "Восточный АО"
    when "ювао"
      "Юго-Восточный АО"
    when "юзао"
      "Юго-Западный АО"
    when "зао"
      "Западный АО"
    when "сзао"
      "Северо-Западный АО"
    when "зелао"
      "Зеленоградский АО"
    when "нао"
      "Новомосковский АО"
    when "тао"
      "Троицкий АО"
    else
      raise "else #{downcased}"
      name
    end
  end

end