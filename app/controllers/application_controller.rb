class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(user)
    if user.roles.include? Role.find_by(slug: "callcenter")
      new_call_center_report_path
    else
      control_root_path
    end
  end
end
