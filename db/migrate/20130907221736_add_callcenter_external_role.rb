class AddCallcenterExternalRole < ActiveRecord::Migration
  def change
    Role.create(name: 'внешний оператор колл-центра', slug: 'callcenter_external', short_name: 'внешний оператор КЦ')
  end
end
