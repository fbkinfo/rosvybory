class Importer

  def self.get_position(field_slug)
      {
          uid: 1,           #нет прямого поля
          created_at: 2,
          adm_region: 3,
          region: 4,
          last_name: 5,
          first_name: 6,
          patronymic: 7,
          phone: 8,
          email: 9,
          current_statuses: 10,
          experience_count: 11,
          previous_statuses: 12,
          can_be_reserv: 13,   #нет прямого поля
          can_be_coord_region: 14, #нет прямого поля
          has_car: 15,
          social_accounts: 16,
          extra: 17
      }[field_slug]
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      puts row.to_json

      #user_app = UserApp.without_state(:rejected).where(phone: '...').first_or_build

    end
  end

  private

  def self.open_spreadsheet(file_path)
    #case File.extname(file.original_filename)
    #  when '.csv' then Csv.new(file.path, nil, :ignore)
    #  when '.xls' then Excel.new(file.path, nil, :ignore)
    #  when '.xlsx' then Excelx.new(file.path, nil, :ignore)
    #  else raise "Unknown file type: #{file.original_filename}"
    #end
    #
    case File.extname(file_path)
      when '.csv' then Roo::Csv.new(file_path, nil, :ignore)
      when '.xls' then Roo::Excel.new(file_path, nil, :ignore)
      when '.xlsx' then Roo::Excelx.new(file_path, nil, :ignore)
      else raise "Unknown file type: #{file_path}"
    end

  end

end