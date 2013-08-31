require 'spec_helper'
require "cancan/matchers"

describe User do
  describe  "#has_role?" do
    let(:user) {create :user}
    let(:role) {create :role}

    it "должно возвращать true если роль есть у пользователя" do
      user.roles << role
      user.has_role?(role.slug).should be_true
    end

    it "должно возвращать false если роли у пользователя нет" do
      user.has_role?(role.slug).should be_false
    end
  end

  describe "#add_role" do
    let(:user) {create :user}
    let(:role) {create :role}

    it "роль должна появляться у пользователя" do
      user.roles.should be_empty
      user.add_role role.slug
      user.save!
      user.roles(true).should include(role)
    end

    it "не должно быть ошибки при повторном добавлении роли" do
      user.add_role role.slug
      user.save!
      expect {user.add_role role.slug}.not_to raise_error
    end
  end

  describe "#remove_role" do
    let(:user) {create :user}
    let(:role) {create :role}

    it "должна исчезнуть у пользователя" do
      user.roles << role
      user.remove_role role.slug
      user.save
      user.roles(true).should be_empty
    end

    it "не должно вызвать ошибки удаление отсутствующей роли" do
      expect {user.remove_role role.slug}.not_to raise_error
    end
  end

  describe "#update_from_user_app" do
    let(:user) {create :user}
    let(:current_role) {create :current_role, slug: "psg"}
    let(:uic1) { create :uic }
    let(:uic2) { create :uic }

    before do
      # pre-setup
      Role.create(:slug => :observer, :name => 'Big brother', :short_name => 'bro')
    end

    it "should create user_current_role for observer" do
      # setup
      user_app = UserApp.new(:uic => uic1.number)
      user_app.can_be_observer = true
      uar = user_app.user_app_current_roles.build(:current_role => current_role)
      uar.keep = '1'
      # excercise
      logger.debug "Rspec User@#{__LINE__}#should create user_current_role for observer"
      user.update_from_user_app(user_app).save
      # verify
      user.user_current_roles.should_not be_empty
      user.user_current_roles.first.current_role.should == current_role
      user.user_current_roles.first.uic.should == uic1
    end

    it "should give priority to user_app_current_role data over user_app data while creating user_current_role" do
      # setup
      user_app = UserApp.new(:uic => uic1.number)
      user_app.can_be_observer = true
      uar = user_app.user_app_current_roles.build(:current_role => current_role, :value => uic2.number.to_s)
      uar.keep = '1'
      # excercise
      user.update_from_user_app(user_app).save
      # verify
      user.user_current_roles.should_not be_empty
      user.user_current_roles.first.current_role.should == current_role
      user.user_current_roles.first.uic.should == uic2
    end

    it 'should accept an array as a parameter' do
      # setup
      user_app1 = create :user_app, skip_phone_verification: true
      user_app2 = create :user_app, skip_phone_verification: true
      uar1 = user_app1.user_app_current_roles.build(current_role: current_role, value: uic1.number.to_s, keep: '1')
      uar2 = user_app2.user_app_current_roles.build(current_role: current_role, value: uic2.number.to_s, keep: '1')
      user = User.new
      # excercise
      user.update_from_user_app([user_app1, user_app2])
      # verify
      user.user_current_roles.should_not be_empty
      user.user_current_roles.first.current_role.should == current_role
      user.user_current_roles.first.uic.should be_nil
      user.last_name.should be_nil
      user.first_name.should be_nil
      user.patronymic.should be_nil
      user.year_born.should be_nil
      user.email.should be_nil
      user.phone.should be_nil
      user.user_app.should be_nil
      user.adm_region_id.should be_nil
      user.region_id.should be_nil
    end

  end

end

