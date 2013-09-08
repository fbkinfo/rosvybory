module ActiveAdmin
  module Views
    class IndexAsCachedTable < ActiveAdmin::Component

      def build(page_presenter, collection, options = {})
        AaCachedTable.new(self).build(page_presenter, collection, options)
      end

      def self.index_name
        "cached_table"
      end
    end
  end
end
