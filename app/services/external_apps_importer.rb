# При импорте сторонней базы необходимо указывать источник (НО) из следующих значений: ГН ("Гражданин Наблюдатель"), Сонар, Голос.
# Пользователи однозначно идентифицируются по номеру мобильного телефона, существующий пользователь обновляется импортируемыми данными. НО пользователя тоже обновляется наряду с другими данными (да, это может привести к переходу пользователя из одного НО в другой).
# Импортируемые телефон и почта автоматически считаются верифицированными.
# В импортируемых таблицах могут быть пустые ячейки (например, у кого-то может не быть отчества).
# Из столбца "Компетенции" необходимо рассматривать только значения "ЮР" и "АС", т.к. других компетенций у нас пока не заведено.
# Утилита должна выводить для каждой строки, которую не удалось распознать/сохранить, номер строки и хоть какое-то описание причины проблем (понадобится впоследствии, когда будем наворачивать на утилиту web-интерфейс).

require 'roo'
class ExternalAppsImporter

  def initialize(file, source_type)
    @file = file
    @source_type = source_type
  end

  def import
    spreadsheet = open_spreadsheet(@file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      model = ExcelUserAppRow.new(attributes_from_row(row))
      if model && !model.save
        logger.info("Error at row #{i}: #{model.errors.inspect}")
      end
    end
  end

  private

  def attributes_from_row(row)
    if row.all?(&:blank?)
      nil
    else
      Hash[ExcelUserAppRow.columns.map {|name, i| [name, row[i]] }]
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
      Logger.new(Rails.root.join("log/user_apps_xls_import-#{stamp}.log"))
    end
  end

end
