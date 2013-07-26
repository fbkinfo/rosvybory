class UserApp < ActiveRecord::Base
  serialize :social_accounts, HashWithIndifferentAccess

  SOCIAL_ACCOUNTS = {vk: "ВКонтакте", fb: "Facebook", twitter: "Twitter", lj: "LiveJournal" , ok: "Одноклассники"}
  SOCIAL_ACCOUNTS.each do |provider_key, provider_name|
    method_n = 'social_'+provider_key.to_s
    define_method(method_n) { social_accounts[provider_key] }
    define_method(method_n+'=') do |val|
      self.social_accounts[provider_key]=val
    end
  end

  #наблюдатель, участник мобильной группы, территориальный координатор, координатор мобильной группы, оператор горячей линии
  NO_STATUS, STATUS_OBSERVER, STATUS_MOBILE, STATUS_COORD_REGION, STATUS_COORD_MOBILE, STATUS_CALLER = 0, 1, 2, 4, 8, 16

  #Член ПРГ в резерве, Член ПРГ УИК, Член ПСГ ТИК, Член ПРГ ТИК
  STATUS_PRG_RESERVE, STATUS_PRG, STATUS_TIC_PSG, STATUS_TIC_PRG = 32, 64, 128, 256

  #Член ПСГ УИК, кандидат, доверенное лицо кандидата, журналист освещающий выборы, координатор
  STATUS_PSG, STATUS_CANDIDATE, STATUS_DELEGATE, STATUS_JOURNALIST, STATUS_COORD = 512, 1024, 2048, 4096, 8192

  FUTURE_STATUSES = {
      STATUS_OBSERVER => "observer",
      STATUS_MOBILE => "mobile",
      STATUS_COORD_REGION => "coord_region",
      STATUS_COORD_MOBILE => "coord_mobile",
      STATUS_CALLER => "caller"
      #STATUS_PRG_RESERVE => "prg_reserve"
  }

  #CURRENT_STATUSES = {STATUS_PRG_RESERVE => "prg_reserve",
  #                    STATUS_PRG => "prg",
  #                    STATUS_TIC_PSG => "tic_psg",
  #                    STATUS_TIC_PRG => "tic_prg"
  #}

  PAST_STATUSES = {
      STATUS_OBSERVER => "observer",
      STATUS_PRG => "prg",
      STATUS_PSG => "psg",
      STATUS_TIC_PRG => "tic_prg",
      STATUS_TIC_PSG => "tic_psg",
      STATUS_CANDIDATE => "candidate",
      STATUS_DELEGATE => "delegate",
      STATUS_JOURNALIST => "journalist",
      STATUS_COORD => "coord"
  }


  FUTURE_STATUSES.each do |status_value, status_name|
    method_n = 'can_be_'+status_name
    define_method(method_n) { desired_statuses & status_value > 0 }
    define_method(method_n+'=') do |val|
      if val
        self.desired_statuses |= status_value
      else
        self.desired_statuses &= ~status_value
      end
    end
  end

  PAST_STATUSES.each do |status_value, status_name|
    method_n = 'was_'+status_name
    define_method(method_n) { previous_statuses & status_value > 0 }
    define_method(method_n+'=') do |val|
      if val
        self.previous_statuses |= status_value
      else
        self.previous_statuses &= ~status_value
      end
    end
  end


end
