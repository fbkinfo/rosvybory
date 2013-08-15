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
  end

  ## GET /user_apps/1/edit
  #def edit
  #end

  # POST /user_apps
  def create
    @user_app = UserApp.new(user_app_params)

    # supposing that nginx is configured like this
    # proxy_set_header   X-Real-IP        $remote_addr;
    # proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;

    @user_app.ip            = request.env['HTTP_X_REAL_IP'] || request.ip
    @user_app.useragent     = request.env['HTTP_USER_AGENT']
    @user_app.forwarded_for = request.env['HTTP_X_FORWARDED_FOR']
    @user_app.organisation = Organisation.where(name: "РосВыборы").first_or_create
    if @user_app.save
      render action: 'done'
      #redirect_to new_user_app_path, notice: 'User app was successfully created.'
    else
      render action: 'new'
    end
  end

  def done

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

    # Only allow a trusted parameter "white list" through.
    def user_app_params
      params.require(:user_app).permit([:data_processing_allowed, :region_id, :adm_region_id, :uic,
                                       :last_name, :first_name, :patronymic, :phone, :email, :has_car, :has_video, :legal_status,
                                       :experience_count, :sex_male, :year_born, :extra] +
                                           UserApp.future_statuses_methods +
                                           UserApp.previous_statuses_methods +
                                           UserApp.current_statuses_methods +
                                           UserApp.social_methods)
    end
end
