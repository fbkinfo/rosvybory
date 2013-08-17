class VerificationsController < ApplicationController

  def create
    if verify_recaptcha
      verification = Verification.new phone_number: params[:phone_number]

      begin
        verification.save!
        session[:verification_id] = verification.id
        render json: { success: true }
      rescue
        render json: { error: $!.to_s }
      end
    else
      flash.delete(:recaptcha_error)
      render json: {error: "Неверно введена капча"}
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
