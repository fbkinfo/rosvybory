class DislocationDecorator < UserDecorator
  delegate :coalesced_region, :to => :user_current_role, :allow_nil => true
  delegate :name, :to => :coalesced_adm_region, :prefix => true, :allow_nil => true
  delegate :name, :to => :coalesced_region, :prefix => true, :allow_nil => true

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

  def coalesced_adm_region
    coalesced_region.try(:closest_adm_region)
  end

  def coalesced_mun_region_name
    coalesced_region.mun_region?? coalesced_region.name : nil
  end

  def user_current_role_region
    Region.where(id: model.user_current_role_region_id).first
  end

  def user_current_role
    @_user_current_role ||= UserCurrentRole.allocate.tap do |ucr|
      attrs = Hash[UserCurrentRole.column_names.map {|c| [c, send("user_current_role_#{c}")]}]
      ucr.init_with 'attributes' => attrs
      ucr.user = self
    end
  end

end
