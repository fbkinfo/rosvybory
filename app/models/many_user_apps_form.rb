class ManyUserAppsForm
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user_apps

  class <<self
    def reflect_on_association(assoc)
      nil
    end
  end

  def initialize(organisation, params = {})
    @organisation = organisation || Organisation.where(name: "РосВыборы").first_or_create

    @user_apps = []
    params.each do |k, v|
      send "#{k}=", v
    end
    build_user_app if @user_apps.blank?
  end

  def file=(value)
    ext = File.extname(value.original_filename)
    eai = ExternalAppsImporter.new(value.tempfile.path, ext)
    eai.import(method(:build_user_app))
  end

  def save
    @user_apps.each &:save
    fail_count == 0
  end

  def added_count
    @user_apps.count(&:persisted?)
  end

  def fail_count
    @user_apps.size - added_count
  end

  def persisted?
    false
  end

  def build_user_app(attrs = {})
    ExcelUserAppRow.new(attrs).tap do |euar|
      euar.organisation = @organisation
      @user_apps << euar
    end
  end

  def user_apps_attributes=(attrs)
    attrs.each do |index, user_app_hash|
      build_user_app user_app_hash unless user_app_hash.values.all?(&:blank?)
    end
  end
end
