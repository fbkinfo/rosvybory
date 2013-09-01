# encoding: utf-8

class CreateCallCenterViolationCategories < ActiveRecord::Migration
  def change
    create_table :call_center_violation_categories do |t|
      t.string :name

      t.timestamps
    end

    CallCenter::ViolationCategory.create([
      { name: "0. Серьезные/часто встречающиеся нарушения" },
      { name: "1. Нарушения при открытии участка" },
      { name: "2. Нарушения при голосовании" },
      { name: "3. Нарушения при подсчете" }
    ])
  end

  def down
    drop_table :call_center_violation_categories
  end
end
