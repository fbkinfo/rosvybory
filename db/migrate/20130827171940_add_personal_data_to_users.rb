class AddPersonalDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :year_born, :integer
    add_column :users, :place_of_birth, :text
    add_column :users, :passport, :text
    add_column :users, :work, :text
    add_column :users, :work_position, :text
    User.reset_column_information

    User.find_each do |user|
      user.update(year_born: user.user_app.year_born) if user.user_app && user.user_app.year_born != 1913 # Из импорта заявки с таким годом
    end

  end
end
