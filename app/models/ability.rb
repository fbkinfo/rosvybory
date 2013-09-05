class Ability
  include CanCan::Ability

  # custom actions:
  #   :change_organisation
  #   :change_adm_region
  #   :change_region

  def initialize(user)
    alias_action :create, :read, :update, :destroy, :to => :crud
    alias_action :do_reject, :to => :reject   # help active admin to find the right ability in user_apps#reject

    if has_role?(user, :admin)
      can :manage, :all
    end

    can :read, Region
    can :read, Organisation
    can :read, Uic
    can :read, ActiveAdmin::Page, :name => "Dashboard"

    can :read, User, :id => user.id

    can :read, CallCenter::Report
    can :read, CallCenter::ViolationCategory
    can :read, CallCenter::ViolationType

    if has_role?(user, :federal_repr)
      #ФП видит заявки своего наблюдательного объединения
      can :crud, UserApp, :organisation_id => user.organisation_id
      can :approve, UserApp, :organisation_id => user.organisation_id
      can :reject, UserApp, :organisation_id => user.organisation_id

      # ФП может просматривать:
      # полный варианта базы своего НО
      # карточки всех волонтёров своего НО, включая координаторов всех видов
      can :crud, User, :organisation_id => user.organisation_id
      can :change_adm_region, User, :organisation_id => user.organisation_id
      can :change_region, User, :organisation_id => user.organisation_id
      can :view_user_contacts, User, :organisation_id => user.organisation_id
      # TODO волонтёров своего НО в координаторском формате без участников МГ и КЦ
      # TODO волонтёров своего НО во формате "Расстановка с контактами" без участников МГ и КЦ
      # TODO всю базу волонтёров в форматах "Расстановка с ФИО" и "Обезличенная расстановка" без участников МГ и КЦ
      can :import, UserApp
      can :view_dislocation, User
      can :crud, MobileGroup, :organisation_id => user.organisation_id

      can :contribute_to, Organisation, :id => user.organisation_id
      can :assign_users, Role, :slug => [:observer, :mobile, :callcenter, :mc, :cc, :tc]

      can [:create, :read], ActiveAdmin::Comment
    end

    if has_role?(user, :tc)
      if user.organisation
        if user.region
          # ТК с заданным районом может просматривать:
          # карточки волонтёров своего района
          can :crud, User, :region_id => user.region_id
          can :crud, UserApp, :region_id => user.region_id
          can :approve, UserApp, :region_id => user.region_id
          can :reject, UserApp, :region_id => user.region_id
          # волонтёров своего района во формате "Расстановка с контактами" без участников МГ и КЦ
          can :view_dislocation, User, :region_id => user.region_id
          can :view_dislocation, Uic, (user.region.has_tic?? user.region : user.adm_region).uics_with_nested_regions
          can :view_user_contacts, User, :region_id => user.region_id
          # TODO волонтёров своего района в координаторском формате без участников МГ и КЦ
          # TODO волонтёров своего округа во формате "Расстановка с ФИО" без участников МГ и КЦ
          # TODO всю базу волонтёров в формате "Обезличенная расстановка" без участников МГ и КЦ
        elsif user.adm_region
          # ТК с незаданным райном может просматривать:
          # карточки волонтёров своего округа
          can :crud, User, :adm_region_id => user.adm_region_id
          can :crud, UserApp, :adm_region_id    => user.adm_region_id
          can :approve, UserApp, :adm_region_id => user.adm_region_id
          can :reject, UserApp, :adm_region_id  => user.adm_region_id
          can :view_dislocation, Uic, user.adm_region.uics_with_nested_regions
          # волонтёров своего округа во формате "Расстановка с контактами" без участников МГ и КЦ
          can :view_dislocation, User, :adm_region_id => user.adm_region_id
          can :view_user_contacts, User, :adm_region_id => user.adm_region_id
          can :change_region, User, :adm_region_id => user.adm_region_id
          # TODO волонтёров своего округа в координаторском формате без участников МГ и КЦ
          # TODO всю базу волонтёров в форматах "Расстановка с ФИО" и "Обезличенная расстановка" без участников МГ и КЦ
        end
        can :assign_users, Role, :slug => [:observer, :mobile, :callcenter, :mc, :cc]
        can :crud, MobileGroup, :organisation_id => user.organisation_id
        can :contribute_to, Organisation, :id => user.organisation_id
      end

      can :import, UserApp

      can [:create, :read], ActiveAdmin::Comment
    end

    if has_role?(user, :mc)
      # КМ может просматривать:

      # карточки волонтёров участников МГ своего НО
      #can :manage, User, :organisation_id => user.organisation_id, :mobile_group_id => user.mobile_group_id

      # TODO всех участников МГ в координаторском формате
      # TODO всех участников МГ в форматах "Сводка МГ с контактами", "Сводка МГ с ФИО" и "Обезличенная сводка МГ"

      can :crud, MobileGroup, :organisation_id => user.organisation_id
      can :contribute_to, Organisation, :id => user.organisation_id

      can [:create, :read], ActiveAdmin::Comment
    end

    if has_role?(user, :callcenter)
      can :create, CallCenter::Report
    end

    if has_role?(user, :cc)
      can [:create, :read], ActiveAdmin::Comment
      CallCenter.constants.each { |m| can(:crud, "CallCenter::#{m}".constantize) }
    end

    can :destroy, UserCurrentRole do |ucr|
      ucr.user && can?(:view_user_contacts, ucr.user)
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end

  private
    def has_role? user, role_name
      user.has_role? role_name
    end
end
