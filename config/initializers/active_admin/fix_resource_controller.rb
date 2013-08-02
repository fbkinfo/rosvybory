#http://staal.io/blog/2013/02/26/mastering-activeadmin/
ActiveAdmin::ResourceController.class_eval do
  before_filter :fix_datetime_filter_inclusion, :only => :index

  private

  def fix_datetime_filter_inclusion
    resource_class.columns.each do |c|
      next unless c.type == :datetime

      if !params["q"].blank? && !params["q"]["#{c.name}_lteq"].blank?
        params["q"]["#{c.name}_lteq"] += " 23:59:59.999999"
      end
    end
  end
end