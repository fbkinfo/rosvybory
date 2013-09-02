class CallCenter::SearchController < ApplicationController
  layout 'call_center'
  respond_to :json

  def dislocations
    @users = User.finder(params[:q]).limit(10)
    respond_with @users
  end

  def current_user
    respond_with User.find(params[:id])
  end

  def uics
    @uics = Uic.where(number: params[:q])
    respond_with @uics
  end
end
