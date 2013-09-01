class CreateCallCenterReporters < ActiveRecord::Migration
  def change
    create_table :call_center_reporters do |t|
      t.integer  :user_id
      t.integer  :uic
      t.integer  :adm_region_id
      t.integer  :mobile_group_id
      t.string   :phone
      t.string   :first_name
      t.string   :patronymic
      t.string   :last_name

      t.timestamps
    end
  end
end
