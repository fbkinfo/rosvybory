class UserAppsController < ApplicationController
  before_action :set_user_app, only: [:show] #, :edit, :update, :destroy]

  ## GET /user_apps
  #def index
  #  @user_apps = UserApp.all
  #end

  ## GET /user_apps/1
  #def show
  #end

  # GET /user_apps/new
  def new
    @user_app = UserApp.new
    gon.recaptcha_key = Recaptcha.configuration.public_key
    CurrentRole.order(:position).each {|cr| @user_app.user_app_current_roles.build current_role_id: cr.id}
  end

  ## GET /user_apps/1/edit
  #def edit
  #end

  # POST /user_apps
  def create
    @user_app = UserApp.new(user_app_params.merge(user_app_extra_params))

    user_app_current_roles = @user_app.user_app_current_roles.to_a
    @user_app.user_app_current_roles = @user_app.user_app_current_roles.select { |a| a.keep }

    if UserAppCreator.save(@user_app)
      session.delete(:verification_id)
      render action: 'done'
      #redirect_to new_user_app_path, notice: 'User app was successfully created.'
    else
      @user_app.user_app_current_roles = user_app_current_roles
      render action: 'new'
    end
  end

  def confirm_email
    respond_to do |format|
      format.html {
        if @user = UserApp.find_by_confirmation_token(params[:key])
          @user.confirm!
          render 'confirmed'
        else
          render 'wrong_token'
        end
      }
    end
  end

  def done

  end

  def new_group_email
    @users = User.where(id: params[:collection_selection])
    render layout: 'custom_layout'
  end

  def send_group_email
    UserMailer.group_email(*params[:group_email].values).deliver
    redirect_to '/control/users', notice: t('.messages_sent')
  end

  def new_group_sms
    @users = User.where(id: params[:collection_selection])
    render layout: 'custom_layout'
  end

  def send_group_sms
    Resque.enqueue(SmsMassSender, phones: params[:group_sms][:phones].delete_if{|i| i.empty?}, message: params[:group_sms][:message])
    redirect_to '/control/users', notice: t('.messages_sent')
  end
  # PATCH/PUT /user_apps/1
  #def update
  #  if @user_app.update(user_app_params)
  #    redirect_to @user_app, notice: 'User app was successfully updated.'
  #  else
  #    render action: 'edit'
  #  end
  #end

  # DELETE /user_apps/1
  #def destroy
  #  @user_app.destroy
  #  redirect_to user_apps_url, notice: 'User app was successfully destroyed.'
  #end

  private



  # Use callbacks to share common setup or constraints between actions.
  def set_user_app
    @user_app = UserApp.find(params[:id])
  end

  def user_app_extra_params
    {
      :ip             => request.env['HTTP_X_REAL_IP'] || request.ip,
      :useragent      => request.env['HTTP_USER_AGENT'],
      :forwarded_for  => request.env['HTTP_X_FORWARDED_FOR'],
      :verification   => Verification.find_by_id(session[:verification_id]),
      :organisation   => Organisation.where(name: "РосВыборы").first_or_create
    }
  end

  # Only allow a trusted parameter "white list" through.
  def user_app_params
    params.require(:user_app).permit([:data_processing_allowed, :region_id, :adm_region_id, :uic,
                                     :last_name, :first_name, :patronymic, :phone, :email, :has_car, :has_video, :legal_status,
                                     {:user_app_current_roles_attributes => [:value, :keep, :current_role_id]},
                                     :experience_count, :sex_male, :year_born, :extra] +
                                         UserApp.future_statuses_methods +
                                         UserApp.previous_statuses_methods +
                                         UserApp.social_methods)
  end
end
