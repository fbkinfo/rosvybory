class Ability
  include CanCan::Ability

  def initialize(user)
    cannot :create, UserApp
    cannot :manage, User

    if has_role?(user, :admin)
      can :manage, :all
    end

    can :read, Region
    can :read, Organisation
    can :read, ActiveAdmin::Page, :name => "Dashboard"

    can :read, User, :id => user.id

    #cannot [:index, :show, :read, :create], ActiveAdmin::Comment

    if has_role?(user, :federal_repr)
      #ФП видит заявки своего наблюдательного объединения
      can :manage, UserApp, :organisation_id => user.organisation_id
      can :manage, User, :organisation_id => user.organisation_id
    end

    if has_role?(user, :tc)
      #ТК видит заявки своего адм. округа или района и только из своего НО
      if user.region && user.organisation
        can :manage, UserApp, :region_id => user.region_id, :organisation_id => user.organisation_id
        can :manage, User, :region_id => user.region_id, :organisation_id => user.organisation_id

        if user.region.kind.adm_region?
          can :manage, UserApp, :adm_region_id => user.region_id, :organisation_id => user.organisation_id
          can :manage, User, :adm_region_id => user.region_id, :organisation_id => user.organisation_id
        end
      end
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
