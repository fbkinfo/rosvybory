class AddPatronymicToCallCenterOperators < ActiveRecord::Migration
  def up
    add_column :call_center_operators, :patronymic, :string
  end

  def down
    remove_column :call_center_operators, :patronymic
  end
end
