class SmsMassSender
  @queue = :mailer

  def self.perform(*args)
    params = args[0]

    results = {}
    message = params['message']
    params['phones'].each do |phone|
      results[phone] = SmsService.send_message(phone, message)
    end

    WorkLog.find_by(id: params['work_log_id']).try(:complete!, results.to_json)
  end
end
