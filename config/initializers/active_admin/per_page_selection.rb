ActiveAdmin::Event.subscribe ActiveAdmin::Resource::RegisterEvent do |resource|

  resource.controller.class_eval do
    def apply_pagination(chain)
      params[:per_page] == '200' ? super.per(200) : super
    end
  end
end

module PaginatedCollectionExtension
  def self.included(base)
    base.class_eval do
      alias_method_chain :page_entries_info, :per_page_selection
    end
  end

  def page_entries_info_with_per_page_selection(options = {})
    content_tag(:span, 'Показывать по ') +
      content_tag(:select, options_for_select([['30'], ['200']], params[:per_page]), :class => 'per-page-selector') +
      ' ' +
      page_entries_info_without_per_page_selection(options).html_safe
  end
end
ActiveAdmin::Views::PaginatedCollection.send :include, PaginatedCollectionExtension
