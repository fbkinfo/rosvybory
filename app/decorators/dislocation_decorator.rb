class DislocationDecorator < UserDecorator
  delegate :name, :to => :coalesced_adm_region, :prefix => true, :allow_nil => true
  delegate :name, :to => :coalesced_region, :prefix => true, :allow_nil => true

  # primary key - user_current_role.id for existing dislocations, user.id for new
  def pk
    user_current_role_id || id
  end

  def coalesced_region
    user_current_role_region || region || adm_region
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

end
