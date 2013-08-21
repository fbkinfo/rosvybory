require 'spec_helper'

describe UserAppCreator do
  context 'when phone number is not in blacklist' do
    specify '.save' do
      user_app = double phone: '1111122222'
      user_app.should_receive(:save)
      UserAppCreator.stub(:blacklisted?).and_return(false)
      UserAppCreator.save(user_app)
    end
  end

  context 'number is blacklisted' do
    specify '.save' do
      user_app = double phone: '1111122222'
      user_app.should_not_receive(:save)
      UserAppCreator.stub(:blacklisted?).and_return(true)
      UserAppCreator.save(user_app)
    end
  end

  specify '.blacklisted?' do
    Blacklist.create phone: '1111122222'
    UserAppCreator.blacklisted?('1111122222').should be_true
    UserAppCreator.blacklisted?('2222211111').should be_false
  end
end
