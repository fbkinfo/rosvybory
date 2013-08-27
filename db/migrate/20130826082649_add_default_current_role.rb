class AddDefaultCurrentRole < ActiveRecord::Migration
  def up
    CurrentRole.create! slug: 'observer', name: "наблюдатель", position: 0
    # User.joins(:roles).where(roles: {slug: 'observer'}).select{|u| u.user_current_roles.count == 0 }
  end
end
