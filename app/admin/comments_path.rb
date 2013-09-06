# Чтобы забирал комментарии из сущности, а не внутренним кодом ActiveAdmin.
# Нужно для отображения коментариев нескольких сущностей одновременно
module ActiveAdmin
  module Comments
    module Views
      class Comments

        def build_comments_with_connected
          @comments = @resource.comments if @resource.respond_to? :comments
          build_comments_without_connected
        end

        alias_method_chain :build_comments, :connected
      end
    end
  end
end