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

    before { Rails.application.load_seed }

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

    context "пользователь с ролью адимна" do
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
        should be_able_to(:manage, UserApp.new(organisation: first_organisation))
      }
    end

    context "пользователь с ролью территориального координатора" do
      let(:user)              { create :user, region: first_adm_region}
      let(:first_adm_region)  { Region.where(name: "Южный АО").first }
      let(:second_adm_region) { Region.where(name: "Северный АО").first }
      let(:first_organisation) { Organisation.where(name: "РосВыборы").first }
      let(:second_organisation) { Organisation.where(name: "КоксВыборы").first }

      before do
        create :role, slug: "tc"
        user.add_role :tc
      end

      it {
        should_not be_able_to(:manage, :all)
        should_not be_able_to(:read, Region.new)
        should_not be_able_to(:manage, Region.new)
        should_not be_able_to(:read, Organisation.new)
        should_not be_able_to(:manage, Organisation.new)
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:read, UserApp.new)

        should_not be_able_to(:manage, User.new(adm_region: first_adm_region))
        should_not be_able_to(:read, User.new(adm_region: second_adm_region))
        should_not be_able_to(:manage, UserApp.new(adm_region: first_adm_region))
        should_not be_able_to(:read, UserApp.new(adm_region: second_adm_region))

        should be_able_to(:manage, User.new(adm_region: first_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, User.new(adm_region: first_adm_region, organisation: second_organisation))

        should be_able_to(:manage, UserApp.new(adm_region: first_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, UserApp.new(adm_region: first_adm_region, organisation: second_organisation))

        should_not be_able_to(:manage, User.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, User.new(adm_region: second_adm_region, organisation: second_organisation))

        should_not be_able_to(:manage, UserApp.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, UserApp.new(adm_region: second_adm_region, organisation: second_organisation))

      }
    end
  end
end

