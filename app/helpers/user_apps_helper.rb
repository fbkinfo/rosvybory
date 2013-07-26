module UserAppsHelper

  def current_status_options
    {
        "Нет" => UserApp::NO_STATUS,
        "Я в резерве составов УИК" => UserApp::STATUS_PRG_RESERVE,
        "Я член УИК с правом решающего голоса" => UserApp::STATUS_PRG,
        "Я член ТИК/ИКМО с правом совещательного голоса" => UserApp::STATUS_TIC_PSG,
        "Я член ТИК/ИКМО с правом решающего голоса" => UserApp::STATUS_TIC_PRG
    }
  end

end
