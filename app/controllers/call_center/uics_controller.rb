class CallCenter::UicsController < ApplicationController
  respond_to :json, :html

  def index
    @uics = Uic.where("lower(name) like :q", q: params[:q].mb_chars.downcase)
    respond_with @uics
  end

  def show
    @uic = Uic.find params[:id]
    respond_with @uic
  end
end
