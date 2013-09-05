# encoding: utf-8

class ManyUserAppsForm
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user_apps
  attr_accessor :ignore_existing

  class <<self
    def reflect_on_association(assoc)
      nil
    end
  end

  def   initialize(organisation, params = {})
    @organisation = organisation || Organisation.where(name: "РосВыборы").first_or_create
    @user_apps = []
    self.ignore_existing = (params[:ignore_existing] != "0")
    params.each do |k, v|
      send "#{k}=", v
    end
    build_user_app if @user_apps.blank?
  end

  def file=(value)
    ext = File.extname(value.original_filename)
    eai = ExternalAppsImporter.new(value.tempfile.path, ext, !ignore_existing)
    eai.organisation = @organisation
    eai.import do |attrs, model|
      @user_apps << model
    end
    value
  end

  def save
    @user_apps.each &:save
    results_count(:failed) == 0
  end

  def user_apps_with_status(status)
    @user_apps.select{|x| x.import_status == status }
  end

  def results_count(status)
    user_apps_with_status(status).count
  end

  def persisted?
    false
  end

  def build_user_app(attrs = {})
    ExcelUserAppRow.new(attrs, !ignore_existing).tap do |euar|
      euar.organisation = @organisation unless euar.organisation
    end
  end

  def user_apps_attributes=(attrs)
    attrs.each do |index, user_app_hash|
      @user_apps << build_user_app(user_app_hash) unless user_app_hash.values.all?(&:blank?)
    end
  end
end
