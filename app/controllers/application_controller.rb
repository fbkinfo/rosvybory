class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from Exception do |exception|
    logger.error exception.class
    logger.error exception.message
    logger.error exception.backtrace.to_s
  end
end
