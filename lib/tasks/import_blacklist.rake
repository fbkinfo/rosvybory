require_relative '../../app/services/spreadsheet_parser'

desc 'Импорт чёрного списка'

task import_blacklist: :environment do
  include SpreadsheetParser

  rows = spreadsheet_rows(Rails.root.join('docs/blacklist.xls').to_s)
  phone_column = rows.take(1).first.each_with_index.select { |v| v.to_s.mb_chars.downcase.include? 'телефон' }.first
  raise 'Column with phone number not found' unless phone_column
  phone_column_index = phone_column.last

  rows.drop(1).map { |v| v[phone_column_index] }.each do |phone|
    if phone.gsub(/[\(\)0-9\-\s\+]/, '').empty?
      Blacklist.where(phone: Verification.normalize_phone_number(phone)).first_or_create!
    else
      puts "Phone number #{phone} skipped due to invalid format"
    end
  end
end
