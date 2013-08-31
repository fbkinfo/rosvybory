class RemoveGotDocsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :got_docs, :boolean, :default => false
  end
end
