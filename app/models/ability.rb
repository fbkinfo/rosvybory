class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :do_reject, :to => :reject   # help active admin to find the right ability in user_apps#reject

    user ||= User.new

    if user.has_role?(:admin)
      can :manage, :all
    else
      can :read, [Region, Organisation, Uic]
      can :read, ActiveAdmin::Page, :name => "Dashboard"

      can [:read, :create], CallCenter::Report
      can :read, [CallCenter::ViolationCategory, CallCenter::ViolationType]

      can :read, User, :id => user.id
    end

    if user.has_role? :db_operator
      # Это люди, которые работают в Штабе, обслуживают приходящих людей: заносят их в базу, назначают роли, делают расстановки
      roles_available = %w(observer callcenter mobile other callcenter_external)
      @@db_operator_roles_restricted ||= Role.pluck(:slug) - roles_available
      #TODO Пока выдаётся список всех пользователей, не критично. User.joins(:user_roles => :role).where(:roles => {:slug => roles_available}) - нужно что-то вроде этого, только включая  пользователей без ролей
      can [:crud, :view_dislocation, :change_adm_region, :change_region, :view_user_contacts], User do |other_user|
        !other_user.has_any_of_roles?(@@db_operator_roles_restricted)
      end

      can [:crud, :approve, :reject, :import], UserApp
      can :contribute_to, Organisation
      can :crud, MobileGroup
      can :dislocation_crud, Dislocation
      can :view_dislocation, Uic

      # не имеет возможность назначать права координаторов и администраторов.
      can :assign_users, Role, :slug => roles_available

      can [:create, :read], ActiveAdmin::Comment
    end

    if user.has_role?(:federal_repr)
      # ФП может просматривать:
      # полный вариант базы своего НО
      # карточки всех волонтёров своего НО, включая координаторов всех видов
      # волонтёров своего НО в координаторском формате без участников МГ и КЦ
      # волонтёров своего НО во формате "Расстановка с контактами" без участников МГ и КЦ
      # всю базу волонтёров в форматах "Расстановка с ФИО" и "Обезличенная расстановка" без участников МГ и КЦ
      can [:crud, :approve, :reject], UserApp, :organisation_id => user.organisation_id
      can :import, UserApp
      can [:crud, :change_adm_region, :change_region, :view_user_contacts], User, :organisation_id => user.organisation_id
      can :view_dislocation, User
      can :dislocation_crud, Dislocation, :organisation_id => user.organisation_id
      can :crud, UserCurrentRole, :user => {:organisation_id => user.organisation_id}
      can :crud, MobileGroup, :organisation_id => user.organisation_id
      can :contribute_to, Organisation, :id => user.organisation_id
      can :assign_users, Role, :slug => [:observer, :mobile, :callcenter, :mc, :cc, :tc, :other, :callcenter_external]

      can [:create, :read], ActiveAdmin::Comment
    end

    if user.has_role?(:tc)
      if user.organisation
        if user.region
          # ТК с заданным районом может просматривать:
          # карточки волонтёров своего района
          # волонтёров своего района во формате "Расстановка с контактами" без участников МГ и КЦ
          can [:crud, :view_dislocation, :view_user_contacts], User, :region_id => user.region_id
          can :view_dislocation, Uic, (user.region.has_tic?? user.region : user.adm_region).uics_with_nested_regions

          can [:crud, :approve, :reject], UserApp, :region_id => user.region_id
          # видит пользователей своего района без расстановок
          # use custom action to prevent OR'ing with Users conditions
          can :dislocation_crud, Dislocation, ["users.region_id = ? and user_current_roles.region_id is null", user.region_id] do |d|
            d.region_id == user.region_id
          end
          # видит пользователей с расстановками в своем районе
          can :dislocation_crud, Dislocation, ["user_current_roles.region_id = ?", user.region_id] do |d|
            d.user_current_role.region_id == user.region_id
          end
        elsif user.adm_region
          # ТК с незаданным райном может просматривать:
          # карточки волонтёров своего округа
          # волонтёров своего округа во формате "Расстановка с контактами" без участников МГ и КЦ
          can [:crud, :view_dislocation, :view_user_contacts, :change_region], User, :adm_region_id => user.adm_region_id
          can :view_dislocation, Uic, user.adm_region.uics_with_nested_regions

          can [:crud, :approve, :reject], UserApp, :adm_region_id => user.adm_region_id
          #видит пользователей своего округа без расстановок
          can :dislocation_crud, Dislocation, ["users.adm_region_id = ? and user_current_roles.region_id is null", user.adm_region_id] do |d|
            user.adm_region.try(:is_or_is_ancestor_of?, d.region)
          end
          #видит всех пользователей с расстановками в своем округе
          can :dislocation_crud, Dislocation, ["(select regions.adm_region_id from regions where regions.id = user_current_roles.region_id) = ?", user.adm_region_id] do |d|
            user.adm_region.try(:is_or_is_ancestor_of?, d.user_current_role_region)
          end
        end

        can :crud, UserCurrentRole, :region_id => user.region_id || user.adm_region_id
        can :assign_users, Role, :slug => [:observer, :mobile, :callcenter, :mc, :cc]
        can :crud, MobileGroup, :organisation_id => user.organisation_id
        can :contribute_to, Organisation, :id => user.organisation_id
      end

      can :import, UserApp

      can [:create, :read], ActiveAdmin::Comment
    end

    if user.has_role?(:mc)
      # КМ может просматривать:
      # карточки волонтёров участников МГ своего НО
      if user.organisation
        can :crud, User, ["users.organisation_id = ? AND users.mobile_group_id IS NOT NULL", user.organisation_id] do |other_user|
          other_user.mobile_group_id.present? && other_user.organisation_id == user.organisation_id
        end
        can :crud, MobileGroup, :organisation_id => user.organisation_id
        can :contribute_to, Organisation, :id => user.organisation_id
      end

      can [:create, :read], ActiveAdmin::Comment
    end

    if user.has_role?(:cc)
      # КК может просматривать только участников КЦ в координаторском формате и формате "Состав КЦ".
      can [:create, :read], ActiveAdmin::Comment
      CallCenter.constants.each { |m| can(:crud, "CallCenter::#{m}".constantize) }
    end

    if user.has_role?(:callcenter_external)
      CallCenter.constants.each { |m| can(:read, "CallCenter::#{m}".constantize) }
      can :crud, CallCenter::Report
    end

    can :destroy, UserCurrentRole do |ucr|
      ucr.user && can?(:view_user_contacts, ucr.user)
    end

  end

end
