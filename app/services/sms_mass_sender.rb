class SmsMassSender
 @queue = :mailer

  def self.perform(*args)
  	message = args[0]['message']

    args[0]['phones'].each do |phone|
    	SmsService.send_message(phone, message)
    end
  end
end