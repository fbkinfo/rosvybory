require 'spec_helper'

describe Dislocation do
  it "Dislocation with DislocationDecorator should return user_current_role.id as id (for selectable_column)" do
    d = Dislocation.new(:id => 234).decorate
    d.stub(:user_current_role_id).and_return(959)
    d.id.should == 959
  end

end

