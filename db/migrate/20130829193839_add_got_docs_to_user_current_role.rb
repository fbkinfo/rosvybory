class AddGotDocsToUserCurrentRole < ActiveRecord::Migration
  def change
    add_column :user_current_roles, :got_docs, :boolean, :default => false
  end
end
