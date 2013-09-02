# encoding: utf-8

class MoveTicsToUics < ActiveRecord::Migration
  def up
    add_column :uics, :kind, :integer
    add_column :uics, :name, :string
    add_column :uics, :parent_id, :integer
    add_index :uics, :parent_id
    change_column :uics, :number, :integer, :null => true, :default => nil

    Uic.reset_column_information

    tics_hache = {} # region_id -> Uic (Tic, i.e.)
    Region.with_tics.find_each do |region|
      tics_hache[region.id] = Uic.where(:kind => Uic.tic_value, :region_id => region.id).first_or_create :name => "ТИК #{region.name}"
    end

    Uic.where(:kind => nil).find_each do |uic|
      uic.update_columns  :kind => Uic.uic_value,
                          :name => "УИК #{uic.number.to_s}",
                          :parent_id => tics_hache[uic.region_id].id
    end

    # fix region_id treated as tic, here the irreversible part goes
    UserCurrentRole.where('region_id is not null').find_each do |ucr|
      ucr.update_columns  :uic_id => tics_hache[ucr.region_id],
                          :region_id => tics_hache[ucr.region_id].try(:region_id)
    end
    UserCurrentRole.where(:region_id => nil).find_each do |ucr|
      ucr.update_columns  :region_id => ucr.user.try(:region_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Reversing this migration will result in data corruption, which we fight a lot with. Reverse it at your own risk."
    Uic.where(:kind => Uic.tic_value).delete_all # do not destryo nested
    remove_index :uics, :parent_id
    remove_column :uics, :kind
    remove_column :uics, :name
    remove_column :uics, :parent_id
    change_column :uics, :number, :integer, :null => false, :default => nil
  end
end
