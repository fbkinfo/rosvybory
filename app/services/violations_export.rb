require 'fileutils'

class ViolationsExport < ActionView::Base
  @queue = :api_export_violations

  def self.perform(*args)
    renderer ||= Renderer.new.renderer
    violations = CallCenter::Report.where(approved: true).map(&:violation).compact
    dir = File.join(Rails.root, 'public/api')
    path = dir + "/violations.json"
    FileUtils.mkdir_p dir
    File.open(path, "w") do |f|
      f.write renderer.render(template: "call_center/violations/index", format: :json, locals: {violations: violations})
    end
  end
end

class Renderer
  def renderer
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.new
    ViewRenderer.new(Rails.root.join('app', 'views'), {}, controller)
  end
end

# A helper class for Renderer
class ViewRenderer < ActionView::Base
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  def default_url_options
     {host: Rails.application.routes.default_url_options[:host]}
  end
end
