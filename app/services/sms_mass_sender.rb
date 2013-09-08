class SmsMassSender
  @queue = :mailer

  def self.spam(current_user, phones, message)
    phones.in_groups_of(500).each do |pg|
      params = {
        phones: pg,
        message: message
      }
      worklog = WorkLog.create  :user_id => current_user.id,
                                :name => 'Sending SMS',
                                :params => options.to_json
      Resque.enqueue(SmsMassSender, options)
    end
  end

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
