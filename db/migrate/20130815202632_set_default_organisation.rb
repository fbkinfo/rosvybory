class SetDefaultOrganisation < ActiveRecord::Migration
  def change
    default_organisation = Organisation.where(name: "РосВыборы").first_or_create
    UserApp.where("organisation_id IS NULL").update_all ['organisation_id = ?', default_organisation.id]
  end
end
