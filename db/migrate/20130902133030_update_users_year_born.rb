class UpdateUsersYearBorn < ActiveRecord::Migration
  def change
    User.all.find_each do |user|
      user.update_column :year_born, user.user_app.year_born if user.year_born.nil? && user.user_app
    end
  end
end
