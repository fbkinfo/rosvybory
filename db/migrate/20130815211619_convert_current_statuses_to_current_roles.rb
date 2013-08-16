class ConvertCurrentStatusesToCurrentRoles < ActiveRecord::Migration
  def up
    map = {
      UserApp::STATUS_PRG_RESERVE => "reserve",
      UserApp::STATUS_PSG => "psg",
      UserApp::STATUS_PRG => "prg",
      UserApp::STATUS_TIC_PSG => "psg_tic",
      UserApp::STATUS_TIC_PRG => "prg_tic"
    }
    keys = map.keys
    UserApp.all.each do |user_app|
      status = user_app.current_statuses
      keys.select do |key|
        key & status > 0
      end.each do |st|
        role_id = CurrentRole.where(slug: map[st]).first.id
        user_app.user_app_current_roles.create! current_role_id: role_id, keep: "1"
      end
    end
  end

  def down
  end
end
