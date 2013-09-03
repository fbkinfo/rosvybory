class CallCenter::DislocationsController < ApplicationController
  respond_to :json

  def index
    q = params[:q].mb_chars.downcase
    @users = User.where("lower(full_name) like :q", q: "%#{q}%").limit(25)
    respond_with @users
  end

  def show
    respond_with User.find(params[:id])
  end
end
