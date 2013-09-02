class CallCenter::UicsController < ApplicationController
  respond_to :json

  def index
    @uics = Uic.where(number: params[:q])
    respond_with @uics
  end

  def show
    @uic = Uic.find params[:id]
    respond_with @uic
  end
end
