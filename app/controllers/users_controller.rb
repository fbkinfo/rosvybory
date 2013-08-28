# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  before_filter :expose_current_roles, only: [:new, :edit, :dislocate]
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
    begin
      @user.current_user = current_user
      if @user.update( params[:dislocation] ? dislocate_params : user_params )
        render json: {status: :ok}, :content_type => 'text/html'
      else
        render (params[:dislocation] ? "dislocate" : "edit"), layout: false
      end
    rescue
      render json: { ошибка: $!.to_s }
    end
  end


  def new
    @app = UserApp.find(params[:user_app_id])
    if @app.reviewed?
      render text: "Заявка уже обработана"
    else
      gon.user_app_id = @app.id
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

  def accessible_fields_dislocate
    [
        :got_docs,
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
