class AddAllParamsToCallCenterPhoneCalls < ActiveRecord::Migration
  def up
    add_column :call_center_phone_calls, :all_params, :hstore
  end

  def down
    remove_column :call_center_phone_calls, :all_params
  end
end
