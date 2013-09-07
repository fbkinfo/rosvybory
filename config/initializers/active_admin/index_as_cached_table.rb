module ActiveAdmin
  module Views
    class IndexAsCachedTable < ActiveAdmin::Component

      def build(page_presenter, collection)
        AaCachedTable.new(self).build(page_presenter, collection)
      end

      def self.index_name
        "cached_table"
      end
    end
  end
end
