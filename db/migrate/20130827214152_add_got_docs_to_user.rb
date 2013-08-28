class AddGotDocsToUser < ActiveRecord::Migration
  def change
    add_column :users, :got_docs, :boolean, :default => false
  end
end
