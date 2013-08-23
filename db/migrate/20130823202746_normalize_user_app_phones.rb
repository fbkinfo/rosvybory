class NormalizeUserAppPhones < ActiveRecord::Migration
  def up
    problematic_user_apps = {}
    UserApp.find_each do |user_app|
      user_app.phone = user_app.phone.gsub /[^\d]+/, '' unless user_app.phone.blank?
      if user_app.phone.length == 11 && (user_app.phone[0] == '8' || user_app.phone[0] == '7')
        puts "Убираю первую цифру у #{user_app.phone}"
        user_app.phone[0]=''
        begin
          user_app.save!
        rescue
          problematic_user_apps[user_app.id] = $!.to_s
        end
      end
    end
    if problematic_user_apps.present?
      puts "Не удалось сохранить заявки: "
      puts problematic_user_apps.to_yaml
    end
  end
end
