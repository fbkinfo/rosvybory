class AddParticipantsCountToUics < ActiveRecord::Migration
  def up
    add_column :uics, :participants_count, :integer
    Uic.reset_column_information
    Uic.find_each &:update_participants_count!
  end

  def down
    remove_column :uics, :participants_count
  end
end
