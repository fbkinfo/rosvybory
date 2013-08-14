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
    subject { ability }
    let(:ability){ Ability.new(user) }
    let(:user){ nil }

    before {Rails.application.load_seed}

    context "пользователь без ролей" do
      let(:user){ create :user }

      it{ should_not be_able_to(:manage, :all) }
      it{ should be_able_to(:read, Region.new) }
      it{ should_not be_able_to(:manage, Region.new) }
      it{ should be_able_to(:read, Organisation.new) }
      it{ should_not be_able_to(:manage, Organisation.new) }
      it{ should_not be_able_to(:read, User.new) }
      it{ should_not be_able_to(:read, UserApp.new) }

    end

    context "пользователь с ролью адимна" do
      let(:user){ create :user}
      before  { user.add_role :admin }

      it{ should be_able_to(:manage, :all) }
    end

    context "пользователь с ролью федерального представителя" do
      let(:user){ create :user, organisation: first_organisation}
      #let(:region){ Region.where(name: "") }
      let(:first_organisation){ create :organisation }
      let(:second_organisation){ create :organisation }

      before  { user.add_role :federal_repr }

      it{ should_not be_able_to(:manage, :all) }
      it{ should be_able_to(:read, Region.new) }
      it{ should_not be_able_to(:manage, Region.new) }
      it{ should be_able_to(:read, Organisation.new) }
      it{ should_not be_able_to(:manage, Organisation.new) }
      it{ should_not be_able_to(:read, User.new) }
      it{ should_not be_able_to(:read, UserApp.new) }
      it{ should_not be_able_to(:read, UserApp.new(organisation: second_organisation)) }
      it{ should be_able_to(:manage, UserApp.new(organisation: first_organisation)) }

    end

    context "пользователь с ролью координатора округа" do
      let(:user){ create :user, region: first_adm_region}
      #let(:region){ Region.where(name: "") }
      let(:first_adm_region){ Region.where(name: "Южный АО").first }
      let(:second_adm_region){ Region.where(name: "Северный АО").first }

      before  { user.add_role :dc }

      it{ should_not be_able_to(:manage, :all) }
      it{ should be_able_to(:read, Region.new) }
      it{ should_not be_able_to(:manage, Region.new) }
      it{ should be_able_to(:read, Organisation.new) }
      it{ should_not be_able_to(:manage, Organisation.new) }
      it{ should_not be_able_to(:read, User.new) }
      it{ should_not be_able_to(:read, UserApp.new) }
      it{ should_not be_able_to(:read, UserApp.new(adm_region: second_adm_region)) }
      it{ should be_able_to(:manage, UserApp.new(adm_region: first_adm_region)) }

    end

  end



end

