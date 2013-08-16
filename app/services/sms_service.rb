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
    '200' => 'неправильный API ID',
    '201' => 'не хватает средств на лицевом счету',
    '202' => 'Неправильно указан получатель',
    '203' => 'Нет текста сообщения',
    '204' => 'Имя отправителя не согласовано с администрацией',
    '205' => 'Сообщение слишком длинное (превышает 8 СМС)',
    '206' => 'Будет превышен или уже превышен дневной лимит на отправку сообщений',
    '207' => 'На этот номер (или один из номеров) нельзя отправлять сообщения',
    '208' => 'Параметр time указан неправильно',
    '209' => 'Вы добавили этот номер (или один из номеров) в стоп-лист',
    '212' => 'Текст сообщения необходимо передать в кодировке UTF-8',
    '220' => 'Сервис временно недоступен, попробуйте чуть позже.',
    '230' => 'Сообщение не принято к отправке, так как на один номер в день нельзя отправлять более 250 сообщений.'
  }

  def self.send_message(number, text)
    result = provider.send to: number, from: AppConfig['smsru_from'], text: text
    raise "Ошибка отправки сообщения: #{ERRORS[result]} [#{result}]" unless result.to_s == '100'
    true
  end

  def self.provider
    return SmsDevProvider.new if Rails.env.development?
    return SmsTestProvider.new if Rails.env.test?
    SmsRu::SMS.new api_id: AppConfig['smsru_api_id']
  end
end
