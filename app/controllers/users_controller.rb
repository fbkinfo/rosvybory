class UsersController < ApplicationController

  include UserAppsHelper

  before_filter :expose_current_roles, only: [:new, :edit, :group_new]
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

  #TODO возможно стоит реализовать через обычные new и create
  # для new идея хорошая, но нет времени сливать (ДК)
  #/users/group_new
  def group_new
    @apps = UserApp.where id: params[:collection_selection]
    @apps = @apps.where %q(state != ?), 'approved'
    gon.user_app_ids = @apps.pluck(:id)
    gon.regions = regions_hash
    case @apps.count
    when 0
      render text: "Заявки уже обработаны"
    when 1
      @app = @apps.first
      gon.user_app_id = @app.id
      @user = User.new_from_app(@app)
      authorize! :create, @user
      render "new", layout: false
    else
      @user = User.new_from_app(@apps)
      gon.user_app_id = @apps.first.id
      authorize! :create, @user
      render layout: false
    end
  end

  # POST /users/group_create
  def group_create
    @apps = UserApp.where id: params[:apps]
    @apps.each do |app|
      user = User.new user_params
      user.email = app.email
      user.phone = Verification.normalize_phone_number(app.phone)
      user.user_app = app
      user.send :generate_password
      user.adm_region_id ||= app.adm_region_id
      user.region_id ||= app.region_id
      user.organisation_id ||= app.organisation_id
      user.save!
      app.confirm_phone! unless app.phone_verified?
      app.confirm_email! unless app.confirmed?
   end
    render json: {status: :ok}, :content_type => 'text/html'
  end



  def new
    @app = UserApp.find(params[:user_app_id])
    if @app.reviewed?
      render text: "Заявка уже обработана"
    else
      gon.user_app_id = @app.id
      gon.user_app_ids = [@app.id]
      gon.regions = regions_hash
      @user = User.new_from_app(@app)
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
    accessible_fields = [
      :adm_region_id,
      :email,
      :password,
      :phone,
      :region_id,
      :user_app_id,
      :role_ids => [],
      :user_current_roles_attributes => [
        :_destroy,
        :current_role_id,
        :id,
        :region_id,
        :uic_id,
        :uic_number,
        :user_id,
      ],
    ]
    if !@user.try(:persisted?)
      accessible_fields += [:organisation_id, :region_id, :adm_region_id]
    else
      accessible_fields << :organisation_id if can?(:change_organisation, @user)
      accessible_fields << :adm_region_id if can?(:change_adm_region, @user)
      accessible_fields << :region_id if can?(:change_region, @user)
    end
    params.require(:user).permit(accessible_fields)
  end

  def expose_current_roles
    gon.current_roles = Hash[CurrentRole.pluck(:id, :slug)]
    gon.observer_role_id = Role.where(slug: "observer").first.id
  end

end
