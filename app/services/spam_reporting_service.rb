class SpamReportingService
  def self.report(user_app)
    add_to_blacklist(user_app.phone)
    user_app.destroy
  end

  def self.add_to_blacklist(phone)
    Blacklist.find_or_create_by(phone: phone)
  end
end
