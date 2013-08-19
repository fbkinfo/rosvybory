class SpamReportingService
  def self.report(user_app)
    # add phone number to black list
    blacklist(user_app.phone)
    user_app.destroy
  end

  def self.blacklist(phone)

  end
end
