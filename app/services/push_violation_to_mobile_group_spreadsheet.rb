class PushViolationToMobileGroupSpreadsheet
  @queue = :push_violation_to_mobile_group_spreadsheet

  class << self
    def perform(*args)
      logger = Logger.new 'log/resque_push_violation_to_mobile_group_spreadsheet.log'
      
      begin
        connect_to_spreadsheet

        report = CallCenter::Report.find args[0]["report_id"]
        
        row = @@sheet.num_rows+1
        @@sheet[row,1] = I18n.l report.created_at, format: :time_first
        @@sheet[row,2] = report.text
        @@sheet[row,3] = report.violation.try(:violation_type).try(:name)
        @@sheet[row,4] = report.reporter.uic.try(:name)
        @@sheet[row,5] = report.reporter.full_name
        @@sheet[row,6] = report.reporter.phone
        @@sheet[row,7] = report.reporter.current_role.try(:name)
        
        @@sheet.save
      rescue Exception => e
        logger.debug e.inspect
      end
    end

    def connect_to_spreadsheet
      config = AppConfig["push_violation_to_mobile_group_spreadsheet"]

      session = GoogleDrive.login config["email"], config["password"]
      sheets = session.spreadsheet_by_key config["spreadsheet_key"]
      @@sheet = sheets.worksheets[config["sheet_index"]]
    end
  end
end