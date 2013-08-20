class UsersController < ApplicationController

  def new
    @app = UserApp.find(params[:user_app_id])
    if @app.reviewed?
      render text: "Заявка уже обработана"
    else
      gon.user_app_id = params[:user_app_id]
      @user = User.new_from_app(@app)
      @user.user_current_roles.build(user_id: @user.id)
      authorize! :manage, @user
      render "new", layout: false
    end
  end


end
