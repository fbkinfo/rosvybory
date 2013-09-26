require 'spec_helper'
require "cancan/matchers"

shared_examples_for 'любой пользователь кроме админа' do
  it {
    should be_able_to(:read, Region)
    should be_able_to(:read, Organisation)
    should be_able_to(:read, Uic)
    should be_able_to(:read, user) #self

    should_not be_able_to(:manage, :all)
    should_not be_able_to(:update, Region)
    should_not be_able_to(:update, Organisation)
    should_not be_able_to(:update, Uic)
  }
end

describe User do

  def user_with_role(role_slug)
    create(:user_with_role, role_slug: role_slug)
  end

  describe "abilities" do
    subject       { ability }
    let(:ability) { Ability.new(user) }
    let(:user)    { nil }

    before {
      #Rails.application.load_seed
      %w(admin observer mobile callcenter federal_repr mc cc other tc db_operator callcenter_external).each do |role_slug|
        create :role, slug: role_slug
      end
    }

    context "пользователь без ролей" do
      let(:user)  { create :user }
      it_behaves_like 'любой пользователь кроме админа'

      it {
        # cannot
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:update, user)
        should_not be_able_to(:destroy, user)
        should_not be_able_to(:import, UserApp)
        should_not be_able_to(:read, UserApp)
        should_not be_able_to(:create, ActiveAdmin::Comment)
        should_not be_able_to(:read, ActiveAdmin::Comment)
      }
    end

    context "пользователь с ролью админа" do
      let(:user)  { create :user_with_role, role_slug: :admin }
      it { should be_able_to(:manage, :all) }
    end

    context "пользователь с ролью оператора БД" do
      let(:user)                { create  :user_with_role, role_slug: :db_operator }
      let(:admin)               { create :user}
      let(:fp)                  { create :user}
      let(:tc)                  { create :user}
      let(:mc)                  { create :user}
      let(:observer)            { create :user}
      it_behaves_like 'любой пользователь кроме админа'

      it {
        # can
        [:crud, :view_dislocation, :change_adm_region, :change_region, :view_user_contacts].each do |action|
          should be_able_to(action, User.new)
        end
        %w(observer callcenter mobile other callcenter_external).each do |allowed_role|
          other_user = user_with_role(allowed_role)
          [:crud, :view_dislocation, :change_adm_region, :change_region, :view_user_contacts].each do |action|
            should be_able_to(action, other_user)
          end
        end

        [:crud, :approve, :reject].each do |action|
          should be_able_to(action, UserApp.new)
        end
        should be_able_to(:import, UserApp)

        should be_able_to(:contribute_to, Organisation.new)
        should be_able_to(:crud, MobileGroup.new)
        should be_able_to(:dislocation_crud, Dislocation.new)
        should be_able_to(:view_dislocation, Uic.new)

        should be_able_to(:create, ActiveAdmin::Comment)
        should be_able_to(:read, ActiveAdmin::Comment)

        # cannot
        %w(admin db_operator federal_repr tc mc cc).each do |restricted_role|
          other_user = user_with_role(restricted_role)
          [:read, :update, :view_dislocation, :change_adm_region, :change_region, :view_user_contacts].each do |action|
            should_not be_able_to(action, other_user)
          end
        end
        should_not be_able_to(:change_organisation, User)
      }
    end

    context "пользователь с ролью федерального представителя" do
      let(:user)                { create :user_with_role, organisation: first_organisation, role_slug: :federal_repr}
      let(:first_organisation)  { create :organisation }
      let(:second_organisation) { create :organisation }

      it_behaves_like 'любой пользователь кроме админа'
      it {
        # can
        should be_able_to(:crud, UserApp.new(organisation: first_organisation))
        should be_able_to(:change_adm_region, user)
        should be_able_to(:change_region, user)
        should be_able_to(:import, UserApp)
        should be_able_to(:view_dislocation, User)
        should be_able_to(:crud, MobileGroup)

        # cannot
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:read, UserApp.new)
        should_not be_able_to(:read, UserApp.new(organisation: second_organisation))
        should_not be_able_to(:change_organisation, user)
      }
    end

    context "пользователь с ролью территориального координатора" do
      let(:user)              { create :user_with_role, adm_region: first_adm_region, organisation: first_organisation, role_slug: :tc }
      let(:first_adm_region)  { Region.where(name: "Южный АО").with_kind(:adm_region).first_or_create }
      let(:second_adm_region) { Region.where(name: "Северный АО").with_kind(:adm_region).first_or_create }
      let(:first_region)      { Region.create parent: first_adm_region, name: "Арбат" }
      let(:second_region)      { Region.create parent: first_adm_region, name: "Якиманка" }
      let(:first_organisation) { Organisation.where(name: "РосВыборы").first_or_create }
      let(:second_organisation) { Organisation.where(name: "КоксВыборы").first_or_create }

      it_behaves_like 'любой пользователь кроме админа'
      it {
        # can
        should be_able_to(:crud, User.new(adm_region: first_adm_region))
        should be_able_to(:crud, UserApp.new(adm_region: first_adm_region))
        should be_able_to(:approve, UserApp.new(adm_region: first_adm_region))
        should be_able_to(:reject, UserApp.new(adm_region: first_adm_region))
        should be_able_to(:change_region, user)
        should be_able_to(:read, UserApp)
        should be_able_to(:import, UserApp)
        should be_able_to(:crud, MobileGroup)

        #проверяем с чужим НО
        enemy_user = User.new(adm_region: first_adm_region, organisation: second_organisation)
        should be_able_to(:crud, enemy_user)
        should be_able_to(:view_dislocation, enemy_user)
        should be_able_to(:view_user_contacts, enemy_user)
        enemy_user_app = UserApp.new(adm_region: first_adm_region, organisation: second_organisation)
        should be_able_to(:crud, enemy_user_app)
        should be_able_to(:approve, enemy_user_app)
        should be_able_to(:reject, enemy_user_app)

        # cannot
        should_not be_able_to(:read, User.new)
        should_not be_able_to(:view_user_contacts, User.new)
        should_not be_able_to(:read, UserApp.new)
        should_not be_able_to(:view_user_contacts, User.new(adm_region: second_adm_region))
        should_not be_able_to(:read, User.new(adm_region: second_adm_region))
        should_not be_able_to(:read, UserApp.new(adm_region: second_adm_region))
        should_not be_able_to(:crud, User.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:crud, User.new(adm_region: second_adm_region, organisation: second_organisation))
        should_not be_able_to(:view_dislocation, User.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:view_user_contacts, User.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:crud, UserApp.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:crud, UserApp.new(adm_region: second_adm_region, organisation: second_organisation))
        should_not be_able_to(:approve, UserApp.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:approve, UserApp.new(adm_region: second_adm_region, organisation: second_organisation))
        should_not be_able_to(:reject, UserApp.new(adm_region: second_adm_region, organisation: first_organisation))
        should_not be_able_to(:reject, UserApp.new(adm_region: second_adm_region, organisation: second_organisation))
        should_not be_able_to(:change_organisation, User)
        should_not be_able_to(:change_adm_region, user)
      }
    end

    context "пользователь с ролью координатора мобильных групп" do
      let(:user)              { create :user_with_role, adm_region: first_adm_region, organisation: first_organisation, role_slug: :mc }
      let(:first_adm_region)  { Region.where(name: "Южный АО").with_kind(:adm_region).first_or_create }
      let(:second_adm_region) { Region.where(name: "Северный АО").with_kind(:adm_region).first_or_create }
      let(:first_region)      { Region.create parent: first_adm_region, name: "Арбат" }
      let(:second_region)      { Region.create parent: first_adm_region, name: "Якиманка" }
      let(:first_organisation) { Organisation.where(name: "РосВыборы").first_or_create }
      let(:second_organisation) { Organisation.where(name: "КоксВыборы").first_or_create }

      it_behaves_like 'любой пользователь кроме админа'

      it {
        # can
        should be_able_to(:crud, MobileGroup)

        # cannot
        should_not be_able_to(:crud, User.new(adm_region: first_adm_region, organisation: first_organisation))
        should_not be_able_to(:crud, UserApp.new(adm_region: first_adm_region, organisation: first_organisation))
        should_not be_able_to(:change_region, user)
        should_not be_able_to(:read, UserApp)
        should_not be_able_to(:import, UserApp)
        should_not be_able_to(:view_dislocation, User)
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
        should_not be_able_to(:change_organisation, User)
        should_not be_able_to(:change_adm_region, user)
      }
    end
  end

end

