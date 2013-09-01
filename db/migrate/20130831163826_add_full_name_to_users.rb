class AddFullNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :full_name, :string, limit: 255 * 3 + 2

    User.reset_column_information
    User.find_each do |user|
      user.update_column full_name: [user.last_name, user.first_name, user.patronymic].join(' ')
    end
  end
end
