class CreateVerifications < ActiveRecord::Migration
  def change
    create_table :verifications do |t|
      t.string      :phone_number
      t.string      :code,          default: nil
      t.boolean     :confirmed
      t.timestamps
    end
  end
end
