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
      user.roles.should include(role)
    end

    it "не должно быть ошибки при повторном добавлении роли" do
      user.add_role role.slug
      expect {user.add_role role.slug}.not_to raise_error
    end
  end

  describe "#remove_role" do
    let(:user) {create :user}
    let(:role) {create :role}

    it "должна исчезнуть у пользователя" do
      user.roles << role
      user.remove_role role.slug
      user.roles.should be_empty
    end

    it "не должно вызвать ошибки удаление отсутствующей роли" do
      expect {user.remove_role role.slug}.not_to raise_error
    end
  end

  describe "abilities" do
    subject       { ability }
    let(:ability) { Ability.new(user) }
    let(:user)    { nil }

    #before { Rails.application.load_seed }

    context "пользователь без ролей" do
      let(:user)  { create :user }

      it {
        should_not be_able_to(:manage, :all)
        should be_able_to(:read, Region.new)
        should_not be_able_to(:manage, Region.new)
        should be_able_to(:read, Organisation.new)
        should_not be_able_to(:manage, Organisation.new)
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:read, UserApp.new)
      }
    end

    context "пользователь с ролью админа" do
      let(:user)  { create :user}
      before do
        create :role, slug: "admin"
        user.add_role :admin
      end

      it { should be_able_to(:manage, :all) }
    end

    context "пользователь с ролью федерального представителя" do
      let(:user)                { create :user, organisation: first_organisation}
      let(:first_organisation)  { create :organisation }
      let(:second_organisation) { create :organisation }

      before do
        create :role, slug: "federal_repr"
        user.add_role :federal_repr
      end

      it {
        should_not be_able_to(:manage, :all)
        should be_able_to(:read, Region.new)
        should_not be_able_to(:manage, Region.new)
        should be_able_to(:read, Organisation.new)
        should_not be_able_to(:manage, Organisation.new)
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:read, UserApp.new)
        should_not be_able_to(:read, UserApp.new(organisation: second_organisation))
        should be_able_to(:crud, UserApp.new(organisation: first_organisation))
        should be_able_to(:import, UserApp)
      }
    end

    context "пользователь с ролью территориального координатора" do
      let(:user)              { create :user, adm_region: first_adm_region, organisation: first_organisation }
      let(:first_adm_region)  { Region.where(name: "Южный АО").with_kind(:adm_region).first_or_create }
      let(:second_adm_region) { Region.where(name: "Северный АО").with_kind(:adm_region).first_or_create }
      let(:first_region)      { Region.create parent: first_adm_region, name: "Арбат" }
      let(:second_region)      { Region.create parent: first_adm_region, name: "Якиманка" }
      let(:first_organisation) { Organisation.where(name: "РосВыборы").first_or_create }
      let(:second_organisation) { Organisation.where(name: "КоксВыборы").first_or_create }

      before do
        create :role, slug: "tc"
        user.add_role :tc
      end

      it {
        should_not be_able_to(:manage, :all)
        should be_able_to(:read, Region.new)
        should_not be_able_to(:manage, Region.new)
        should be_able_to(:read, Organisation.new)
        should_not be_able_to(:manage, Organisation.new)
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:read, UserApp.new)

        should_not be_able_to(:manage, User.new(adm_region: first_adm_region))
        should_not be_able_to(:read, User.new(adm_region: second_adm_region))
        should_not be_able_to(:manage, UserApp.new(adm_region: first_adm_region))
        should_not be_able_to(:read, UserApp.new(adm_region: second_adm_region))

        should be_able_to(:crud, User.new(adm_region: first_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, User.new(adm_region: first_adm_region, organisation: second_organisation))

        should be_able_to(:crud, UserApp.new(adm_region: first_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, UserApp.new(adm_region: first_adm_region, organisation: second_organisation))

        should_not be_able_to(:manage, User.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, User.new(adm_region: second_adm_region, organisation: second_organisation))

        should_not be_able_to(:manage, UserApp.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, UserApp.new(adm_region: second_adm_region, organisation: second_organisation))

        should_not be_able_to(:import, UserApp)
        should be_able_to(:read, UserApp)
      }
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

  end

end

