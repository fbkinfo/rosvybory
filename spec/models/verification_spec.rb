require 'spec_helper'

describe Verification do

  it { should validate_presence_of :phone_number }

  let(:verification) { Verification.new }

  it 'should generate the code' do
    verification.code.should match /\d{6}/
  end

  it 'should trigger sms service' do
    SmsService.should_receive(:send_message)
    verification = Verification.create phone_number: '1234567890'
  end

  describe 'проверка', :focus do
    context 'когда телефон уже использован другим пользователем' do
      before { create :user, phone: '1111122222' }

      specify 'не проходит' do
        verification = Verification.new phone_number: '1111122222'
        verification.should have(1).errors_on(:phone_number)
      end
    end

    context 'когда телефон используется в другой заявке' do
      before { create :user_app, :verified, phone: '1111122222' }
      specify 'не проходит' do
        verification = Verification.new phone_number: '1111122222'
        verification.should have(1).errors_on(:phone_number)
      end
    end
  end

  describe '#confirm!' do
    before do
      # we don't want to actually send SMS messages in tests
      SmsService.stub(:send_message)
    end

    context 'with valid code' do
      specify 'should be successful' do
        verification = Verification.new code: '999999', phone_number: '1234512345'
        expect(verification.confirm!('999999')).to be_true
        verification.confirmed?.should be_true
      end
    end

    context 'with invalid code' do
      specify 'should NOT be successful' do
        verification = Verification.new code: '999999', phone_number: '1234512345'
        expect(verification.confirm!('444444')).to be_false
      end
    end
  end

end
