class ConvertDcRcToTc < ActiveRecord::Migration
  def up
    Role.create!(slug: "tc", name: "территориальный координатор", short_name: "ТК") unless Role.find_by_slug('tc')

    users = User.includes(:roles).where("roles.slug" => ["dc", "rc"])
    users.each do |u|
      u.add_role 'tc'
      u.remove_role 'dc'
      u.remove_role 'rc'
    end

    Role.destroy_all(slug: ['dc', 'rc'])
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
