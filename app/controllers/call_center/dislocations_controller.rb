class CallCenter::DislocationsController < ApplicationController
  respond_to :json

  def index
    @users = User.finder(params[:q]).limit(10)
    respond_with @users
  end

  def show
    respond_with User.find(params[:id])
  end
end