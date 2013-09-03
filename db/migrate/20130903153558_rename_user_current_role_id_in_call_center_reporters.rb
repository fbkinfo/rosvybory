class RenameUserCurrentRoleIdInCallCenterReporters < ActiveRecord::Migration
  def up
    change_table :call_center_reporters do |t|
      t.rename :user_current_role_id, :current_role_id
    end
  end

  def down
    change_table :call_center_reporters do |t|
      t.rename :current_role_id, :user_current_role_id
    end
  end
end
