class AddDboperatorRole < ActiveRecord::Migration
  def up
    Role.create slug: 'db_operator', name: 'оператор базы данных', short_name: 'ОБД'
  end

  def down
    Role.where(slug: 'db_operator').first.try(:destroy)
  end
end
