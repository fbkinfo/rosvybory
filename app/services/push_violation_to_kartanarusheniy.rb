class PushViolationToKartanarusheniy
  @queue = :push_violation_to_kartanarusheniy

  def self.perform(*args)
    params = args[0]
    r = CallCenter::Report.find params["report_id"]

    uri = 'http://www.kartanarusheniy.org/2013-09-08/create_remote.json'
    response = Net::HTTP.post_form(uri, {
        message: {uik: r.reporter.uic.try(:name), auto_code: 77, description: r.text, city: "Москва", contacts: "call-центр"},
        secret: "DJh5EKzZfhHwM8VZVq8Q"
    })
  end
end
