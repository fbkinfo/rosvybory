class CallCenter::DislocationsController < ApplicationController
  layout 'call_center'
  respond_to :json

  def index
    @users = User.order('name').finder(params[:q]).limit(40)
    respond_with @users
  end

end
