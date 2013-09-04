class CreateWorkLogs < ActiveRecord::Migration
  def change
    create_table :work_logs do |t|
      t.references :user
      t.string :name
      t.text :params
      t.string :state, :null => false, :default => 'pending'
      t.text :results

      t.timestamps
    end
  end
end
