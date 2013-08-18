class SetHasVideoToFalseForNil < ActiveRecord::Migration
  def up
    UserApp.where(has_video: nil).update_all has_video: false
  end

  def down
    
  end
end
