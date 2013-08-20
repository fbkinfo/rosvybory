class UsersController < ApplicationController

  before_filter :expose_current_roles, only: [:new]

  def new
    @app = UserApp.find(params[:user_app_id])
    if @app.reviewed?
      render text: "Заявка уже обработана"
    else
      gon.user_app_id = @app.id
      @user = User.new_from_app(@app)
      @user.user_current_roles.build(user_id: @user.id)
      authorize! :create, @user
      render "new", layout: false
    end
  end

  # POST /users
  def create
    @user = User.new(user_params)
    authorize! :create, @user
    if @user.save
      render json: {status: :ok}, :content_type => 'text/html'
    else
      render "new", layout: false
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  #def set_user
  #  @user = User.find(params[:id])
  #end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit([:email, :region_id, :role_ids, :adm_region_id, :phone,
                                      :organisation_id, :password, :user_app_id])
  end

  def expose_current_roles
    gon.current_roles = Hash[CurrentRole.pluck(:id, :slug)]
    gon.observer_role_id = Role.where(slug: "observer").first.id
  end

end
