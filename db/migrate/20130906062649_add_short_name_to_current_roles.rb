class AddShortNameToCurrentRoles < ActiveRecord::Migration
  def change
    add_column :current_roles, :short_name, :string

    abbrevs = {
      "резерв составов УИК" => "резерв УИК",
      "Член УИК с правом совещательного голоса" => "УПСГ",
      "Член УИК с правом решающего голоса" => "УПРГ",
      "Член ТИК с правом совещательного голоса" => "ТПСГ",
      "Член ТИК с правом решающего голоса" => "ТПРГ",
      "Представитель СМИ" => "СМИ"
    }

    CurrentRole.reset_column_information
    CurrentRole.find_each do |current_role|
      current_role.update_column :short_name, abbrevs[current_role.name] || current_role.name
    end
  end

  def down
    remove_column :current_roles, :short_name
  end
end
