class SmsMassSender
  @queue = :mailer
  QUEUE_MAX_COUNT = 200
  def self.spam(current_user, phones, message)

    phones.in_groups_of(QUEUE_MAX_COUNT, false).each_with_index do |pg, index|
      options = {
        phones: pg,
        message: message,
        group: "#{index*QUEUE_MAX_COUNT+1} - #{(index+1)*QUEUE_MAX_COUNT} of #{phones.size}"
      }
      worklog = WorkLog.create  :user_id => current_user.id,
                                :name => "Sending SMS, #{options[:group]}",
                                :params => options.to_json
      Resque.enqueue(SmsMassSender, options.merge(work_log_id: worklog.id))
    end
  end

  def self.perform(*args)
    params = args[0]

    results = {}
    message = params['message']
    params['phones'].each do |phone|
      results[phone] = SmsService.send_message(phone, message)
    end

    log = WorkLog.find_by id: params['work_log_id']
    log.try :complete!, results.to_json
    failed = results.count{|k,v| v == SmsService::ERRORS['207'] || v == '207'}
    UserMailer.sms_results(log.user.email, failed).deliver if log
  end
end
