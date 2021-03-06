class VerificationsController < ApplicationController

  def create
    if AppConfig["captcha_enabled"] && verify_recaptcha || !AppConfig["captcha_enabled"]
      verification = Verification.new phone_number: params[:phone_number]

      begin
        verification.save!
        session[:verification_id] = verification.id
        render json: { success: true, simulation: AppConfig["simulate_phone_confirmation"] }
      rescue
        render json: { error: $!.to_s }
      end
    else
      flash.delete(:recaptcha_error)
      render json: {error: "Неверно введены слова с картинки"}
    end
  end

  def confirm
    verification = Verification.find_by_id session[:verification_id]

    if verification.present? && verification.confirm!(params[:verification_code])
      render json: { success: true }
    else
      render json: { error: 'Something went wrong' }
    end
  end
end
