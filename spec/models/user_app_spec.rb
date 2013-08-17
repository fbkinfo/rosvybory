require 'spec_helper'

describe UserApp do
  it { should belong_to :region }
  it { should belong_to :adm_region }

  it { should validate_presence_of :first_name }

  # дописать остальные валидации
  # ...

  describe 'отправка формы должна быть с подтвержденным номером телефона' do
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
        verification = Verification.new phone_number: '11111', confirmed: true
        @user_app = create :user_app, verification: verification, phone: '11111'
      end

      specify { @user_app.should be_valid }
      specify { @user_app.phone_verified.should be_true }
    end
  end

  describe "#approve" do
    let(:verification) { Verification.new phone_number: '1234567', confirmed: true }
    subject { create(:user_app, verification: verification, phone: '1234567') }

    it "обновляет статус" do
      subject.approve!

      expect(subject.reload.state_name).to eq(:approved)
    end

    it "создает User" do
      expect {
        subject.approve!
      }.to change(User, :count).by(1)
    end
  end
end
