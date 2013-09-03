require_relative '../../app/services/spreadsheet_parser'

desc 'Импорт чёрного списка'

task import_blacklist: :environment do

  if ENV['FILE'].nil?
    raise 'No FILE passed, try docs/blacklist.xls or docs/blacklist2.xlsx '
  end

  include SpreadsheetParser

  rows = spreadsheet_rows(ENV['FILE'])
  phone_column = rows.take(1).first.each_with_index.select { |v| v.to_s.mb_chars.downcase.include? 'телефон' }.first
  raise 'Column with phone number not found' unless phone_column
  phone_column_index = phone_column.last

  rows.drop(1).each do |row|
    phone = row[phone_column_index]
    if phone.gsub(/[\(\)0-9\-\s\+]/, '').empty?
      blacklisted_record = Blacklist.where(phone: Verification.normalize_phone_number(phone)).first_or_create!
      blacklisted_record.update(info: row.join("\n")) if blacklisted_record.info.blank?
    else
      puts "Phone number #{phone} skipped due to invalid format, record uid #{row[0]}"
    end
  end
end
