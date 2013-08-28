class CreateNominationSources < ActiveRecord::Migration
  def change
    create_table :nomination_sources do |t|
      t.string :name
      t.string :variant

      t.timestamps
    end
    add_column :user_current_roles, :nomination_source_id, :integer
  end
end
