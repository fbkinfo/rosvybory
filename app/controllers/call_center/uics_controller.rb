class CallCenter::UicsController < ApplicationController
  respond_to :json, :html

  def index
    if params[:q]
      q = params[:q].mb_chars.downcase
      @uics = Uic.where("lower(name) like :q", q: "%#{q}%").limit(50)
      respond_with @uics
    elsif params[:id].present?
      respond_with Uic.find(params[:id])
    else
      render nothing: true
    end
  end

  def show
    @uic = Uic.find params[:id]
    respond_with @uic
  end

  def by_user
    respond_with UserCurrentRole.where(user_id: params[:user_id]).first.try(:uic)
  end
end
