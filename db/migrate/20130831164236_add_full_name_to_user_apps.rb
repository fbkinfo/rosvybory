class AddFullNameToUserApps < ActiveRecord::Migration
  def change
    add_column :user_apps, :full_name, :string, limit: 255 * 3 + 2

    UserApp.reset_column_information
    UserApp.find_each do |user|
      user.update_column full_name: [user.last_name, user.first_name, user.patronymic].join(' ')
    end

  end
end
