class CallCenter::Violation < ActiveRecord::Base
  belongs_to :violation_type
  has_one :report

  def to_json
    text = report.text rescue ''
    uic_name = report.reporter.uic.name rescue ''
    { violation_type: violation_type.try(:name), uic: uic_name, text: text, created_at: created_at }.to_json
  end

  class << self
    def create_json_load
      path = File.join('public/', 'violations.json')
      File.open(path, "w") { |f| f.write(all.map(&:to_json).join("\n"))  }
    end
  end
end
