class UserMailer < ActionMailer::Base
  default from: "dont-reply@rosvybory.org"

	include Resque::Mailer

  def group_email(emails, subject, body)
    mail(to: emails, subject: subject, body: body)
  end

  def sms_results email, failed
    @failed = failed
    mail(to: email, subject: 'Failed sms messages')
  end
end
