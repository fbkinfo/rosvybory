class AddOrganisationIdToUserApps < ActiveRecord::Migration
  def change
    add_reference :user_apps, :organisation, index: true
  end
end
