class UserAppCreator
  def self.save(user_app)
    blacklisted?(user_app.phone) || user_app.save
  end

  def self.blacklisted?(phone)
    Blacklist.where(phone: phone).exists?
  end
end
