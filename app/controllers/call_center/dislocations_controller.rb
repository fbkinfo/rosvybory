class CallCenter::DislocationsController < ApplicationController
  respond_to :json

  def index
    # Пришлось это сделать потому, когда меняешь значение select2, то он сюда идёт за человеком.
    if params[:q].present?
      q = params[:q].mb_chars.downcase
      @users = User.where("lower(full_name) like :q", q: "%#{q}%").limit(25)
      respond_with @users
    elsif params[:id].present?
      respond_with User.find(params[:id])
    else
      render nothing: true
    end
  end

  def show
    respond_with User.find(params[:id])
  end

  def by_phone
    respond_with User.find_by_phone(params[:phone].strip)
  end
end
