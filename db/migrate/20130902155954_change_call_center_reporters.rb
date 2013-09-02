class ChangeCallCenterReporters < ActiveRecord::Migration
  def up
    change_table :call_center_reporters do |t|
      t.remove :role
      t.integer :user_current_role_id
      t.rename :uic, :uic_id
    end
  end

  def down
    change_table :call_center_reporters do |t|
      t.remove :user_current_role_id
      t.string :role
      t.rename :uic_id, :uic
    end
  end
end
