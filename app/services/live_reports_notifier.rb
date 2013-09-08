class LiveReportsNotifier
  def self.instance
    @instance ||= LiveReportsNotifier.new
  end

  def initialize
    @redis = Redis.new
  end

  def broadcast(report)
    hash = report.as_json(:only => [:id])
    @redis.publish "reports", hash.to_json
  end
end
