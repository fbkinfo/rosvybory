class CreateMobileGroups < ActiveRecord::Migration
  def change
    create_table :mobile_groups do |t|
      t.references :organisation, index: true
      t.string :name
      t.references :adm_region
      t.references :region

      t.timestamps
    end
  end
end
