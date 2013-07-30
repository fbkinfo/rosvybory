class AddYearBornAndSexToUserApp < ActiveRecord::Migration
  def change
    add_column :user_apps, :year_born, :integer
    add_column :user_apps, :sex_male, :boolean
  end
end
