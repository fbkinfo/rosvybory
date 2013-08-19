require 'spec_helper'

describe 'Registration' do
  specify 'should accept correct registration' do
    pending
  end
end

describe 'Admin::UsersController' do
  let(:user) {create :user}
  before do
    create :role, slug: "observer"
    sign_in user
  end

  it 'пароль пользователя сменяется, если предыдущий указан верно или подвтерждение нового совпадает' do
    visit edit_password_control_user_path(user)

    new_password = 'password'
    old_password = user.password
    within 'form' do

      find('#user_current_password').set "wrong_password"
      find('#user_password').set new_password
      find('#user_password_confirmation').set new_password

      click_button 'Обновить пароль'
    end
    user.password.should == old_password

    #current_path.should == edit_password_control_user_path(user)
    within 'form' do
      find('#user_current_password').set old_password
      find('#user_password').set new_password
      find('#user_password_confirmation').set "non-matching"

      click_button 'Обновить пароль'
    end

    user.password.should == old_password
    #current_path.should == edit_password_control_user_path(user)

    within 'form' do
      find('#user_current_password').set old_password
      find('#user_password').set new_password
      find('#user_password_confirmation').set new_password

      click_button 'Обновить пароль'
    end

    user.password.should == new_password
  end
end