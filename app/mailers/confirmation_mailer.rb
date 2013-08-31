#encoding: utf-8
class ConfirmationMailer < ActionMailer::Base

	include Resque::Mailer

  default from: "confirmation@rosvybory.org"

  def email_confirmation(user)
  	@user = user
    mail(to: user['email'], subject: 'База наблюдателей: подтверждение адреса электронной почты')
  end

end
