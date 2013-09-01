module AdmRegionDelegation

  def self.included(base)
    base.class_eval do
      ransacker :adm_region_id do
        rt = Region.arel_table
        subselect = rt.project(rt[:adm_region_id]).where(rt[:id].eq(arel_table[:region_id]))
        Arel::SqlLiteral.new("(#{subselect.to_sql})")
      end

      before_save :set_region_id_from_adm_region_id
    end
  end

  def adm_region_id
    @adm_region_id || region.try(:adm_region_id)
  end

  def adm_region_id=(value)
    @adm_region_id = value
  end

  def adm_region
    Region.where(:id => adm_region_id).first if adm_region_id
  end

  private
    def set_region_id_from_adm_region_id
      if @adm_region_id && adm_region && (region.blank? || !adm_region.is_or_is_ancestor_of?(region))
        self.region = adm_region
      end
    end

end
