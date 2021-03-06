FactoryGirl.define do
  factory :user_app do
    first_name        { Faker::NameRU.first_name }
    last_name         { Faker::NameRU.last_name }
    patronymic        { Faker::NameRU.patronymic }
    email             { Faker::Internet.email }
    phone             { Faker::PhoneNumber.short_phone_number }
    adm_region        { FactoryGirl.create(:region, :adm_region) }
    region            { |a| FactoryGirl.create(:region, parent: a.adm_region) }
    desired_statuses  { UserApp::STATUS_OBSERVER }
    has_car           false
    has_video         false
    legal_status      { UserApp::LEGAL_STATUS_NO }
    experience_count  0
    sex_male          true
    year_born         1976
    ip                '192.168.1.1'

    trait :verified do
      after(:build) do |user_app|
        user_app.verification = Verification.create phone_number: user_app.phone, confirmed: true
      end
    end

    trait :rejected do
      state 'rejected'
    end

    trait :spam do
      state 'spammed'
    end

    trait :approved do
      state 'approved'
    end

  end
end
