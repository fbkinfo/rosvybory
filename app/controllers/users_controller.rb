class UsersController < ApplicationController

  before_filter :expose_current_roles, only: [:new, :edit]
  before_filter :set_user, only: [:edit, :update]

  def edit
    authorize! :update, @user
    gon.user_id = @user.id
    render "edit", layout: false
  end

  def update
    authorize! :update, @user
    if @user.update(user_params)
      render json: {status: :ok}, :content_type => 'text/html'
    else
      render "edit", layout: false
    end
  end


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
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
     accessible_fields = [:email, :region_id, :role_ids, :adm_region_id, :phone,
                                     :password, :user_app_id,
                                     :role_ids => [],
                                     :user_current_roles_attributes =>[:id, :current_role_id, :region_id, :uic_id, :user_id, :_destroy]
                                ]
     accessible_fields << :organisation_id if !@user.try(:persisted?) || can?(:change_organisation, @user)
     params.require(:user).permit(accessible_fields)
  end

  def expose_current_roles
    gon.current_roles = Hash[CurrentRole.pluck(:id, :slug)]
    gon.observer_role_id = Role.where(slug: "observer").first.id
  end

end
