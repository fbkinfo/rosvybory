class WorkLog < ActiveRecord::Base
  belongs_to :user

  def complete!(res)
    self.state = 'completed'
    self.results = res
    save
  end
end
