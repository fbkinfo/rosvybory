require 'roo'

module SpreadsheetParser

  def open_spreadsheet(file_path, file_type = File.extname(file_path))
    case file_type.downcase
      when '.csv'
        Roo::Csv.new(file_path, nil, :ignore)
      when '.xls'
        Roo::Excel.new(file_path, nil, :ignore)
      when '.xlsx'
        Roo::Excelx.new(file_path, nil, :ignore)
      else
        raise "Unknown file type: #{file_path}"
    end
  end

  def spreadsheet_rows(file_path, file_type = File.extname(file_path))
    spreadsheet = open_spreadsheet file_path, file_type

    Enumerator.new do |y|
      (spreadsheet.first_row..spreadsheet.last_row).each { |i| y.yield spreadsheet.row(i) }
    end
  end
end