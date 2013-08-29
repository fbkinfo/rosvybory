require 'spec_helper'
require "cancan/matchers"

describe User do

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
        user.save!
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
        user.save!
      end

      it {
        # can
        should be_able_to(:read, Organisation.new)
        should be_able_to(:read, Region.new)
        should be_able_to(:crud, UserApp.new(organisation: first_organisation))
        should be_able_to(:change_adm_region, user)
        should be_able_to(:change_region, user)
        should be_able_to(:import, UserApp)
        should be_able_to(:view_dislocation, User)

        # cannot
        should_not be_able_to(:manage, :all)
        should_not be_able_to(:manage, Region.new)
        should_not be_able_to(:manage, Organisation.new)
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:read, UserApp.new)
        should_not be_able_to(:read, UserApp.new(organisation: second_organisation))
        should_not be_able_to(:change_organisation, user)
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
        user.save
      end

      it {
        # can
        should be_able_to(:read, Region.new)
        should be_able_to(:read, Organisation.new)
        should be_able_to(:crud, User.new(adm_region: first_adm_region, organisation: first_organisation))
        should be_able_to(:crud, UserApp.new(adm_region: first_adm_region, organisation: first_organisation))
        should be_able_to(:change_region, user)
        should be_able_to(:read, UserApp)
        should be_able_to(:import, UserApp)
        should be_able_to(:view_dislocation, User)

        # cannot
        should_not be_able_to(:manage, :all)
        should_not be_able_to(:manage, Region.new)
        should_not be_able_to(:manage, Organisation.new)
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:read, UserApp.new)
        should_not be_able_to(:manage, User.new(adm_region: first_adm_region))
        should_not be_able_to(:read, User.new(adm_region: second_adm_region))
        should_not be_able_to(:manage, UserApp.new(adm_region: first_adm_region))
        should_not be_able_to(:read, UserApp.new(adm_region: second_adm_region))
        should_not be_able_to(:manage, User.new(adm_region: first_adm_region, organisation: second_organisation))
        should_not be_able_to(:manage, UserApp.new(adm_region: first_adm_region, organisation: second_organisation))
        should_not be_able_to(:manage, User.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, User.new(adm_region: second_adm_region, organisation: second_organisation))
        should_not be_able_to(:manage, UserApp.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:manage, UserApp.new(adm_region: second_adm_region, organisation: second_organisation))
        should_not be_able_to(:change_organisation, User.new)
        should_not be_able_to(:change_adm_region, user)
      }
    end
  end

end

