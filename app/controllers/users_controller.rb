class UsersController < ApplicationController

  include UserAppsHelper

  before_filter :expose_current_roles,
      only: [:new, :edit, :group_new, :dislocate]
  before_filter :set_user, only: [:edit, :update, :dislocate]

  def dislocate
    authorize! :update, @user
    gon.user_id = @user.id
    render "dislocate", layout: false
  end

  def edit
    authorize! :update, @user
    gon.user_id = @user.id
    render "edit", layout: false
  end

  def update
    authorize! :update, @user
    @user.valid_roles = Role.accessible_by(current_ability, :assign_users)
    if @user.update( params[:dislocation] ? dislocate_params : user_params )
      @user.send_reset_password_instructions if params[:send_password]
      render json: {status: :ok}, :content_type => 'text/html'
    else
      render (params[:dislocation] ? "dislocate" : "edit"), layout: false
    end
  end

  #TODO возможно стоит реализовать через обычные new и create
  # для new идея хорошая, но нет времени сливать (ДК)
  #/users/group_new
  def group_new
    @apps = UserApp.where id: params[:collection_selection]
    @apps, @rejected = @apps.inject([[], []]) do |pair, app|
      if reason = app.can_not_be_approved?
        pair.last << [app, reason]
      else
        pair.first << app
      end
      pair
    end
    logger.debug "UsersController@#{__LINE__}#group_new #{@apps.inspect} #{@rejected.inspect}" if logger.debug?
    gon.user_app_ids = @apps.to_a.map(&:id)
    gon.regions = regions_hash
    case @apps.count
    when 0
      if @rejected.present?
        render partial: 'rejected', layout: false
      else
        render text: "Заявки уже обработаны"
      end
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
      user.last_name = app.last_name
      user.first_name = app.first_name
      user.patronymic = app.patronymic
      user.year_born = app.year_born
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
    @user.valid_roles = Role.accessible_by(current_ability, :assign_users)
    begin
      # @user.save may raise exception in after_create
      user_save_result = @user.save
    rescue Exception => e
      @user.errors.add :base, e.to_s
      user_save_result = false
    end
    if user_save_result
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

  def accessible_fields_dislocate
    [
        :year_born,
        :place_of_birth,
        :passport,
        :work,
        :work_position,
        :last_name,
        :first_name,
        :full_name,
        :patronymic,
        :address,
        :user_current_roles_attributes => [
            :_destroy,
            :current_role_id,
            :id,
            :region_id,
            :nomination_source_id,
            :uic_id,
            :uic_number,
            :user_id,
            :got_docs,
        ],
    ]
  end

  def user_params
    accessible_fields = [
      :adm_region_id,
      :email,
      :password,
      :phone,
      :region_id,
      :user_app_id,
      :role_ids => [],
    ]
    if !@user.try(:persisted?)
      accessible_fields += [:organisation_id, :region_id, :adm_region_id]
    else
      accessible_fields << :organisation_id if can?(:change_organisation, @user)
      accessible_fields << :adm_region_id if can?(:change_adm_region, @user)
      accessible_fields << :region_id if can?(:change_region, @user)
      accessible_fields << :region_id if can?(:change_region, @user)
    end
    accessible_fields += accessible_fields_dislocate

    params.require(:user).permit(accessible_fields)
  end

  def dislocate_params
    params.require(:user).permit(accessible_fields_dislocate)
  end

  def expose_current_roles
    gon.current_roles = Hash[CurrentRole.pluck(:id, :slug)]
    gon.observer_role_id = Role.where(slug: "observer").first.id
  end

end
