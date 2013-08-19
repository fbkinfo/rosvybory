class DeviseMailer < Devise::Mailer
  default from: "dont-reply@rosvybory.org"

  include Resque::Mailer

  def reset_password_instructions(record, token, opts={})
    @user = User.find(record['id'])
    @token = @user.reset_password_token
    mail(to: @user.email, subject: 'Росвыборы: инструкция по восстановлению пароля')
  end
end
