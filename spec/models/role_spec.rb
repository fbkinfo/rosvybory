require 'spec_helper'

describe Role do

  subject { create :role }

  it { should be_valid }
  it { should validate_uniqueness_of :name }
  it { should validate_uniqueness_of :short_name }
  it { should validate_uniqueness_of :slug }

  describe :class do
    it 'should respond to :common' do
      role = create :role
      adm  = create :role, slug: 'admin'
      Role.common.should == [role]
    end
  end

end
