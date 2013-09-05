class CallCenter::ViolationsController < ApplicationController
  respond_to :json
  def index
    @violations = CallCenter::Violation.all
    path = File.join(Rails.root, 'public/api/violations.json')
    File.open(path, "w") { |f| f.write(render("index").join("\n"))  }
  end
end
