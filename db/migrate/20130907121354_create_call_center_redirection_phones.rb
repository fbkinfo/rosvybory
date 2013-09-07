class CreateCallCenterRedirectionPhones < ActiveRecord::Migration
  def change
    create_table :call_center_redirection_phones do |t|
      t.string :name
      t.string :number
    end
  end
end
