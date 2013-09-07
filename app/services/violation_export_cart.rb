class ViolationExportCart
  @queue = :api_export_violations

  def self.perform(violation_id)
    r = Violation.find(violation_id).report
    uri = 'http://www.kartanarusheniy.org/2013-09-08/create_remote.json'
    response = Net::HTTP.post_form(uri, {
        message: {uik: r.reporter.uic.name, auto_code: 77, description: r.report.text, city: "Москва", contacts: "call-центр"},
        secret: "DJh5EKzZfhHwM8VZVq8Q"
    })
  end
end
