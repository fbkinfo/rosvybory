class SmsPasswordsController < ActiveAdmin::Devise::PasswordsController

  protected
    def after_sending_reset_password_instructions_path_for(resource)
      raise super.inspect
    end
end
