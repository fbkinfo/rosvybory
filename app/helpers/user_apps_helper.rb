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


  def legal_status_human_readable(status)
    {
        UserApp::LEGAL_STATUS_NO => "Нет",
        UserApp::LEGAL_STATUS_YES  => "Есть",
        UserApp::LEGAL_STATUS_LAWYER => "Адвокат"
    }[status]
  end

  def status_human_readable(status)
    statuses = []
    UserApp.all_statuses.each do |st, st_name|
      if st & status > 0
        statuses << t("user_app.status.#{st_name}")
      end
    end
    statuses.join(", ")
  end

end
