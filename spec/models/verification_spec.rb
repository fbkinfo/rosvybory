require 'spec_helper'

describe Verification do

  it { should validate_presence_of :phone_number }

  let(:verification) { Verification.new }

  it 'generates the code' do
    verification.code.should match /\d{6}/
  end

  context 'with simulate_phone_confirmation option on' do
    before {AppConfig['simulate_phone_confirmation'] = true}
    it 'does NOT trigger sms service' do
      SmsService.should_not_receive(:send_message_with_worklog)
      verification = Verification.create phone_number: '1234567890'
    end
  end

  context 'with simulate_phone_confirmation option off' do
    before {AppConfig['simulate_phone_confirmation'] = false}
    it 'triggers sms service' do
      SmsService.should_receive(:send_message_with_worklog)
      verification = Verification.create phone_number: '1234567890'
    end
  end

  describe 'проверка' do
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

      context 'with simulate_phone_confirmation option on' do
        before {AppConfig['simulate_phone_confirmation'] = true}
        it 'is successful' do
          verification = Verification.new code: '999999', phone_number: '1234512345'
          expect(verification.confirm!('444444')).to be_true
        end
      end

      context 'with simulate_phone_confirmation option off' do
        before {AppConfig['simulate_phone_confirmation'] = false}
        it 'is NOT successful' do
          verification = Verification.new code: '999999', phone_number: '1234512345'
          expect(verification.confirm!('444444')).to be_false
        end
      end
    end
  end

end
