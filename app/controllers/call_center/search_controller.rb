class CallCenter::SearchController < ApplicationController
  layout 'call_center'
  respond_to :json

  def dislocations
    @users = User.finder(params[:q]).limit(40)
    respond_with @users
  end

  def uics
    @uics = Uic.where(number: params[:q])
    respond_with @uics
  end
end
