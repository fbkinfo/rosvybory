require 'spec_helper'

describe SmsService do
  before do
    @provider = double
    SmsService.stub(:provider).and_return(@provider)
    AppConfig['smsru_from'] = '79037701262'
  end

  it 'sends SMS message on valid conditions' do
    @provider.should_receive(:send).with(to: '555666', from: '79037701262', text: 'Hello').and_return('100')
    expect(SmsService.send_message('555666', 'Hello')).to eq(SmsService::ERRORS['100'])
  end

  it 'returns error description if service returned invalid code' do
    @provider.should_receive(:send).with(to: '555666', from: '79037701262', text: 'Hello').and_return('204')
    expect(SmsService.send_message('555666', 'Hello')).to eq(SmsService::ERRORS['204'])
  end

  it 'sets user wrong_phone to true if service returned 207' do
    user = create :user
    @provider.should_receive(:send).with(to: user.phone, from: '79037701262', text: 'Hello').and_return('207')
    expect{ SmsService.send_message(user.phone, 'Hello') }.to change{ user.reload.wrong_phone }.from(false).to(true)
  end
end
