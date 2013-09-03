ActiveAdmin::Event.subscribe ActiveAdmin::Resource::RegisterEvent do |resource|

  resource.controller.class_eval do
    def apply_pagination(chain)
      params[:per_page] == '200' ? super.per(200) : super
    end
  end
end


ActiveAdmin::Views::PaginatedCollection.class_eval do

  def page_entries_info_super(options = {})
    if options[:entry_name]
      entry_name   = options[:entry_name]
      entries_name = options[:entries_name] || entry_name.pluralize
    elsif collection_is_empty?
      entry_name   = I18n.t "active_admin.pagination.entry", :count => 1, :default => 'entry'
      entries_name = I18n.t "active_admin.pagination.entry", :count => 2, :default => 'entries'
    else
      key = "activerecord.models." + collection.first.class.model_name.i18n_key.to_s
      entry_name   = I18n.translate key, :count => 1,               :default => collection.first.class.name.underscore.sub('_', ' ')
      entries_name = I18n.translate key, :count => collection.size, :default => entry_name.pluralize
    end

    if collection.num_pages < 2
      case collection_size
        when 0; I18n.t('active_admin.pagination.empty',    :model => entries_name)
        when 1; I18n.t('active_admin.pagination.one',      :model => entry_name)
        else;   I18n.t('active_admin.pagination.one_page', :model => entries_name, :n => collection.total_count)
      end
    else
      offset = (collection.current_page - 1) * collection.limit_value
      if @display_total
        total  = collection.total_count
        I18n.t 'active_admin.pagination.multiple', :model => entries_name, :total => total,
               :from => offset + 1, :to => offset + collection_size
      else
        I18n.t 'active_admin.pagination.multiple_without_total', :model => entries_name,
               :from => offset + 1, :to => offset + collection_size
      end
    end
  end

  def page_entries_info(options = {})
    #TODO вызов super или super(options) почему-то не получает параметры, поэтому код старого метода продублирован в page_entries_info_super
    orig = page_entries_info_super options
    content_tag(:span, 'Показывать по') + content_tag(:select, options_for_select([['30'], ['200']], params[:per_page]), :class => 'per-page-selector') + ' '+raw(orig)
  end
end
