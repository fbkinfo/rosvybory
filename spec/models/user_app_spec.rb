require 'spec_helper'

describe UserApp do
  it { should belong_to :region }
  it { should belong_to :adm_region }

  it { should validate_presence_of :first_name }
  it { should validate_presence_of :email}

  it { should allow_value("prefix.email@addresse.foo").for(:email) }
  it { should_not allow_value("@email@addresse.foo").for(:email) }
  it { should_not allow_value("@email@addresse.foo").for(:email) }
  it { should_not allow_value("ema il@addresse.foo").for(:email) }
  it { should_not allow_value("ema.\ il@addresse.foo").for(:email) }
  it { should_not allow_value("ema\ .il@addresse.foo").for(:email) }

  # TODO:  дописать остальные валидации

  describe '.create' do
    context 'без подтвержденного номера телефона' do
      before  { @user_app = build :user_app }
      specify do
        @user_app.should_not be_valid
        @user_app.errors[:phone].should include 'не подтвержден'
      end
    end

    context 'с подтвержденным, но измененным номером телефона' do
      before do
        verification = Verification.new phone_number: '1234567', confirmed: true
        @user_app = build :user_app, verification: verification, phone: '87878787'
      end

      specify { @user_app.should_not be_valid }
    end

    context 'с подтвежденным номером' do
      before do
        verification = Verification.new phone_number: '1111122222', confirmed: true
        @user_app = create :user_app, verification: verification, phone: '1111122222'
      end

      specify { @user_app.should be_valid }
      specify { @user_app.phone_verified.should be_true }
    end

    context 'с существующей отклоненной заявкой на тот же телефон' do
      before do
        create :user_app, :verified, :rejected, phone: '1111122222'
      end

      specify do
        @user_app = build :user_app, :verified, phone: '1111122222'
        @user_app.should be_valid
      end
    end

    context 'верификация телефона' do
      before { @user_app = create :user_app, :verified }
      specify 'должна сохраняться при последующем редактировании' do
        @user_app = UserApp.find @user_app.id
        @user_app.year_born = '1980'
        @user_app.save

        @user_app.should be_valid
        @user_app.phone_verified.should be_true
      end
    end
  end
end
