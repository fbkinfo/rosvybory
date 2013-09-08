class SmsDevProvider
  def send(params)
    path = Rails.root.join 'tmp', "sms_#{Time.now.to_i}.html"
    File.open(path, 'w') do |f|
      f.write message(params)
      f.close
    end
    Launchy.open "file:///#{path}"
    '100'
  end

  def message(params)
    params.symbolize_keys!
    html = ''
    html << "<b>FROM:</b> #{params[:from]}<br/>\n"
    html << "<b>TO:</b> #{params[:to]}<br/>\n"
    html << "<b>MESSAGE:</b> #{params[:text]}<br/>\n"
    html
  end
end

class SmsTestProvider
  def send(params)
    '100'
  end
end

class SmsService
  ERRORS = {
    '100' => 'Ok (100)',
    '200' => 'неправильный API ID (200)',
    '201' => 'не хватает средств на лицевом счету (201)',
    '202' => 'Неправильно указан получатель (202)',
    '203' => 'Нет текста сообщения (203)',
    '204' => 'Имя отправителя не согласовано с администрацией (204)',
    '205' => 'Сообщение слишком длинное (превышает 8 СМС) (205)',
    '206' => 'Будет превышен или уже превышен дневной лимит на отправку сообщений (206)',
    '207' => 'На этот номер (или один из номеров) нельзя отправлять сообщения (207)',
    '208' => 'Параметр time указан неправильно (208)',
    '209' => 'Вы добавили этот номер (или один из номеров) в стоп-лист (209)',
    '212' => 'Текст сообщения необходимо передать в кодировке UTF-8 (212)',
    '220' => 'Сервис временно недоступен, попробуйте чуть позже (220)',
    '230' => 'Сообщение не принято к отправке, так как на один номер в день нельзя отправлять более 250 сообщений (230)'
  }

  def self.send_message(number, text)
    result = provider.send to: number, from: AppConfig['smsru_from'], text: text
    ERRORS[result] || result
  end

  def self.send_message_with_worklog(number, text, worklog_text = nil)
    options = {phones: [number], message: (worklog_text ? "%% #{worklog_text} %%" : text)}
    worklog = WorkLog.create  :user_id => nil,
                              :name => 'Sending single SMS',
                              :params => options.to_json
    #Resque.enqueue(SmsMassSender, options.merge(work_log_id: worklog.id))
    results[number] = provider.send to: number, from: AppConfig['smsru_from'], text: text
    worklog.try(:complete!, results.to_json)
    ERRORS[results[number]] || results[number]
  end

  def self.provider
    return SmsDevProvider.new if Rails.env.development?
    return SmsTestProvider.new if Rails.env.test?
    SmsRu::SMS.new api_id: AppConfig['smsru_api_id']
  end
end
