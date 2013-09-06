class DislocationDecorator < UserDecorator
  delegate :name, :to => :user_current_role_adm_region, :prefix => true, :allow_nil => true
  delegate :name, :to => :user_current_role_region, :prefix => true, :allow_nil => true

  # primary key - user_current_role.id for existing dislocations, user.id for new
  def pk
    user_current_role_id || user_id
  end

  def id
    user_current_role_id
  end

  def user_id
    model.id
  end

  def user_current_role_adm_region
    user_current_role_region.try(:adm_region)
  end

  def user_current_role_mun_region_name
    user_current_role_region.try(:mun_region?)? user_current_role_region.name : nil
  end

  def user_current_role_region
    user_current_role.try(:region)
  end

  def user_current_role
    @_user_current_role ||= UserCurrentRole.allocate.tap do |ucr|
      attrs = Hash[UserCurrentRole.column_names.map {|c| [c, send("user_current_role_#{c}")]}]
      ucr.init_with 'attributes' => attrs
      ucr.user = self
      ucr.region ||= region
    end
  end

end
