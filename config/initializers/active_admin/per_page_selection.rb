ActiveAdmin::Event.subscribe ActiveAdmin::Resource::RegisterEvent do |resource|

  resource.controller.class_eval do
    def apply_pagination(chain)
      if bypass_pagination?
        super.per(100000)
      elsif params[:per_page] == '200'
        super.per(200)
      else
        super
      end
    end

    def batch_action
      if bypass_pagination?
        if params[:filters].present?
          params[:q] = Rack::Utils.parse_nested_query(params[:filters])['q'].with_indifferent_access
        end
        params[:collection_selection] = collection_ids
      end
      super
    end

    private
      unless instance_methods.include?(:collection_ids)
        def collection_ids
          collection.collect(&:id) # cannot pluck, it's decorated with draper
        end
      end

      def bypass_pagination?
        params[:all_pages] == '1' && params[:batch_action].present? && params[:collection_selection_toggle_all] == 'on'
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
