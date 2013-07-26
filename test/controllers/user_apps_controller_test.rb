require 'test_helper'

class UserAppsControllerTest < ActionController::TestCase
  setup do
    @user_app = user_apps(:one)
  end

  #test "should get index" do
  #  get :index
  #  assert_response :success
  #  assert_not_nil assigns(:user_apps)
  #end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_app" do
    assert_difference('UserApp.count') do
      post :create, user_app: {  }
    end

    assert_redirected_to user_app_path(assigns(:user_app))
  end

  #test "should show user_app" do
  #  get :show, id: @user_app
  #  assert_response :success
  #end
  #
  #test "should get edit" do
  #  get :edit, id: @user_app
  #  assert_response :success
  #end
  #
  #test "should update user_app" do
  #  patch :update, id: @user_app, user_app: {  }
  #  assert_redirected_to user_app_path(assigns(:user_app))
  #end
  #
  #test "should destroy user_app" do
  #  assert_difference('UserApp.count', -1) do
  #    delete :destroy, id: @user_app
  #  end
  #
  #  assert_redirected_to user_apps_path
  #end
end
