class AddSessionLimitableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unique_session_id, :string, :limit => 20
  end
end
