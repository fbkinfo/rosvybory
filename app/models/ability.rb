class Ability
  include CanCan::Ability

  # custom actions:
  #   :change_organisation
  #   :change_adm_region
  #   :change_region

  def initialize(user)
    alias_action :create, :read, :update, :destroy, :to => :crud

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
      can :crud, UserApp, :organisation_id => user.organisation_id
      can :approve, UserApp, :organisation_id => user.organisation_id
      can :reject, UserApp, :organisation_id => user.organisation_id

      # ФП может просматривать:
      # полный варианта базы своего НО
      # карточки всех волонтёров своего НО, включая координаторов всех видов
      can :crud, User, :organisation_id => user.organisation_id
      can :change_adm_region, User, :organisation_id => user.organisation_id
      can :change_region, User, :organisation_id => user.organisation_id

      # TODO волонтёров своего НО в координаторском формате без участников МГ и КЦ
      # TODO волонтёров своего НО во формате "Расстановка с контактами" без участников МГ и КЦ
      # TODO всю базу волонтёров в форматах "Расстановка с ФИО" и "Обезличенная расстановка" без участников МГ и КЦ
      can :import, UserApp
      can :view_dislocation, User
    end

    if has_role?(user, :tc)
      #ТК видит заявки своего адм. округа или района и только из своего НО
      if user.organisation
        if user.region
          can :crud, UserApp, :region_id => user.region_id, :organisation_id => user.organisation_id
          can :approve, UserApp, :region_id => user.region_id, :organisation_id => user.organisation_id
          can :reject, UserApp, :region_id => user.region_id, :organisation_id => user.organisation_id
          # ТК с заданным районом может просматривать:
          # карточки волонтёров своего района
          can :crud, User, :region_id => user.region_id, :organisation_id => user.organisation_id
          # TODO волонтёров своего района в координаторском формате без участников МГ и КЦ
          # TODO волонтёров своего района во формате "Расстановка с контактами" без участников МГ и КЦ
          # TODO волонтёров своего округа во формате "Расстановка с ФИО" без участников МГ и КЦ
          # TODO всю базу волонтёров в формате "Обезличенная расстановка" без участников МГ и КЦ
        elsif  user.adm_region
          can :crud, UserApp, :adm_region_id    => user.adm_region_id, :organisation_id => user.organisation_id
          can :approve, UserApp, :adm_region_id => user.adm_region_id, :organisation_id => user.organisation_id
          can :reject, UserApp, :adm_region_id  => user.adm_region_id, :organisation_id => user.organisation_id
          # ТК с незаданным райном может просматривать:
          # карточки волонтёров своего округа
          can :crud, User, :adm_region_id => user.adm_region_id, :organisation_id => user.organisation_id
          can :change_region, User, :adm_region_id => user.adm_region_id, :organisation_id => user.organisation_id
          # TODO волонтёров своего округа в координаторском формате без участников МГ и КЦ
          # TODO волонтёров своего округа во формате "Расстановка с контактами" без участников МГ и КЦ
          # TODO всю базу волонтёров в форматах "Расстановка с ФИО" и "Обезличенная расстановка" без участников МГ и КЦ
        end
      end

      can :import, UserApp
      can :view_dislocation, User
    end

    if has_role?(user, :mc)
      # КМ может просматривать:

      # карточки волонтёров участников МГ своего НО
      #can :manage, User, :organisation_id => user.organisation_id, :mobile_group_id => user.mobile_group_id

      # TODO всех участников МГ в координаторском формате
      # TODO всех участников МГ в форматах "Сводка МГ с контактами", "Сводка МГ с ФИО" и "Обезличенная сводка МГ"
    end

    if has_role?(user, :cc)
      # TODO КК может просматривать только участников КЦ в координаторском формате и формате "Состав КЦ".
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
