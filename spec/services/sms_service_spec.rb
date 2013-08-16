require 'spec_helper'

describe SmsService do
  before do
    @provider = double
    SmsService.stub(:provider).and_return(@provider)
  end

  it 'should send SMS message on valid conditions' do
    @provider.should_receive(:send).with(to: '555666', from: '79037701262', text: 'Hello').and_return('100')
    expect(SmsService.send_message('555666', 'Hello')).to be_true
  end

  it 'should raise exception if service returned invalid code' do
    @provider.should_receive(:send).with(to: '555666', from: '79037701262', text: 'Hello').and_return('204')
    expect { SmsService.send_message('555666', 'Hello') }.to raise_error
  end
end
