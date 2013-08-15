class FillCurrentRoles < ActiveRecord::Migration
  def up
    current_roles = [
      ["reserve", "резерв составов УИК", 1],
      ["psg", "Член УИК с правом совещательного голоса", 2],
      ["prg", "Член УИК с правом решающего голоса", 3],
      ["psg_tic", "Член ТИК с правом совещательного голоса", 4],
      ["prg_tic", "Член ТИК с правом решающего голоса", 5],
    ]

    current_roles.each do |slug, name, position|
      CurrentRole.create! slug: slug, name: name, position: position
    end
  end

  def down
    CurrentRole.destroy_all
  end
end
