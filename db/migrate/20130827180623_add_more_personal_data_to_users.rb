class AddMorePersonalDataToUsers < ActiveRecord::Migration
  def change

    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
    add_column :users, :patronymic, :string

    add_column :users, :address, :text

    User.reset_column_information

    User.find_each do |user|
      user.update(
              last_name: user.user_app.last_name,
              first_name: user.user_app.first_name,
              patronymic: user.user_app.patronymic
      ) if user.user_app
    end
  end
end
