class CallCenter::UicsController < ApplicationController
  respond_to :json, :html

  def index
    q = params[:q].mb_chars.downcase
    @uics = Uic.where("lower(name) like :q", q: "%#{q}%").limit(50)
    respond_with @uics
  end

  def show
    @uic = Uic.find params[:id]
    respond_with @uic
  end
end
