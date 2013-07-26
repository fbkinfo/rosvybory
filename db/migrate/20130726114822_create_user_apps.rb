class CreateUserApps < ActiveRecord::Migration
  def change
    create_table :user_apps do |t|
      #t.references :region

      t.string  :last_name
      t.string  :first_name
      t.string  :patronymic
      t.string  :phone
      t.string  :email
      t.integer :uic
      t.integer :current_status, :default => 0
      t.integer :experience_count, :default => 0
      t.integer :previous_statuses, :default => 0
      #t.boolean :uic_reserve_acceptable
      #t.boolean :coordinator_acceptable
      t.boolean :has_car
      t.string  :social_accounts
      t.text    :extra
      t.integer :legal_status
      t.integer :desired_statuses, :default => 0

      t.string  :app_code
      t.integer :app_status
      #t.references :user

      t.timestamps
    end
  end
end
